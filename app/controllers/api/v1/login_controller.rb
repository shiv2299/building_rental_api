module Api 
  module V1
    class LoginController < ApplicationController
      def signup
        user = User.new(user_params)
        begin
          if user.save
            if params[:user_type]=="AGENT"
              agentDetail = AgentDetail.new(user_id:user.id,REN:params[:REN],SPA_signed:params[:SPA_signed])
              if agentDetail.save
                login = User.where("email=? AND password=? AND is_active=true",params[:email],params[:password]).joins("INNER JOIN agent_details b on users.id = b.user_id").select("*")
                render json: {status: '1', msg: 'saved user and agent details',data: login[0]}, status: :ok
              else
                render json: {status: '0', msg: 'agent details not saved', data: login.errors}, status: :ok
              end
            else
              render json: {status: '1', msg: 'Saved User',data: user}, status: :ok
            end
          else
            render json: {status: '0', msg: 'Error signing up', data: user.errors}, status: :ok  
          end
        rescue StandardError, AnotherError => e
          if e.message.include? "PG::UniqueViolation: ERROR:"
            render json: {status: '0', msg: 'Email or User Name or Contact already exists', data: user.errors}, status: :ok  
          else
            render json: {status: '0', msg: 'Error caused', data: e}, status: :ok  
          end
        end
      end

      def userLogin
        login = User.where("email=? AND password=? AND user_type=? AND is_active=true",params[:email],params[:password], params[:user_type])
        p login.length
        if login.length>0
          if login[0].user_type!="ADMIN"
            login = User.where("email=? AND password=? AND is_active=true",params[:email],params[:password]).joins("INNER JOIN agent_details b on users.id = b.user_id").select("*")
          end
          render json: {status: '1', msg: 'Login Successful', data:login}, status: :ok
        else
          p "userLogin"
          email = User.where("email=? AND user_type=? AND is_active=true",params[:email], params[:user_type])
          p email
          if email.length>0
            render json: {status: '0', msg: 'Incorrect Password'}, status: :ok  
          else
            p "ghusa"
            render json: {status: '0', msg: 'Email not found'}, status: :ok  
          end
        end
      end

      def removeUser
        user = User.find(params[:id])
        if user.update_attributes(params.permit(:is_active))
          render json: {status: '1', msg: 'user deleted', data: user}, status: :ok
        else
          render json: {status: '0', msg: 'user not deleted', data: user.errors}, status: :ok  
        end
      end

      def updateUser
        user = User.find(params[:id])
        type = ""
        if user.update(user_params)
          type = user.user_type
        end
        if type=="AGENT"
          agent = AgentDetail.where("user_id=?",params[:id])
          p agent
          if agent[0].update(agent_params)
            agent = AgentDetail.where("user_id=?",params[:id]).joins("INNER JOIN users b on agent_details.user_id = b.id").select("*")
            render json: {status: '1', msg: 'user updated', data: agent[0]}, status: :ok
          else
            render json: {status: '0', msg: 'user not updated', data: agent[0].errors}, status: :ok  
          end
        elsif type=="ADMIN"
          render json: {status: '1', msg: 'user updated', data: user}, status: :ok
        else
          render json: {status: '0', msg: 'user not updated', data: user.errors}, status: :ok  
        end
      end

      def getUsers
        user = User.order('created_at DESC').where("is_active=true");
        render json: {status: '1', msg: 'All user details Loaded', data: user}, status: :ok
      end

      def getSingleUser
        user = User.where("id=?",params[:id])
        if user.length>0
          if user[0][:user_type] == 'AGENT'
            user = AgentDetail.where("user_id=?",params[:id]).joins("INNER JOIN users b on agent_details.user_id = b.id").select("*")
          end
        end
        render json: {status: '1', msg: 'User details Loaded', data: user[0]}, status: :ok
      end

      def getAgents
        user = User.joins("INNER JOIN agent_details b on users.id = b.user_id").select("*").where("users.user_type = 'AGENT' AND users.is_active=true AND b."+'"SPA_signed"'+"=true");
        if(user.length>0)
          render json: {status: '1', msg: 'All Agent details Loaded', data: user}, status: :ok
        else
          render json: {status: '0', msg: 'No active agent found', data: user}, status: :ok
        end
      end


      
      private
      def user_params
        params.permit(
          :name,
          :password,
          :user_type,
          :contact,
          :email,
          :is_active,
          :token
        )
      end
      def agent_params
        params.permit(
          :REN,
          :SPA_signed
        )
      end
    end
  end
end