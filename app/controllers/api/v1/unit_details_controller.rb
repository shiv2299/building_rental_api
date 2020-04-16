module Api
  module V1
    class UnitDetailsController < ApplicationController

      def index
        unit_detail = UnitDetail.order('created_at DESC');
        render json: {status: '1', msg: 'All unit details Loaded', data: unit_detail}, status: :ok
      end

      def show
        unit_detail = UnitDetail.find(params[:id])
        render json: {status: '1', msg: 'Unit details Loaded', data: unit_detail}, status: :ok
      end

      def create
        unit_details = UnitDetail.new(unit_detail_params)
        if unit_details.save
          render json: {status: '1', msg: 'saved unit details',data:unit_details}, status: :ok
        else
          render json: {status: '0', msg: 'Unit details not saved',data:unit_details.error}, status: :unprocessable_entity
        end
      end

      def destroy
        unit_detail = UnitDetail.find(params[:id])
        if unit_detail.destroy
          render json: {status: '1', msg: 'deleted unit detail',data:unit_detail}, status: :ok
        else
          render json: {status: '0', msg: 'unit detail not deleted',data:unit_detail}, status: :ok
        end
      end

      def update
        unit_detail = UnitDetail.find(params[:id])
        if unit_detail.update_attributes(unit_detail_params)
          render json: {status: '1', msg: 'unit details updated',data:unit_detail}, status: :ok
        else
          render json: {status: '0', msg: 'unit detail not updated',data:unit_detail}, status: :ok
        end
      end

      private
      def unit_detail_params
        params.permit(
          :unit_block,
          :unit_block_name,
          :unit_number,
          :unit_floor,
          :unit_price,
          :unit_height,
          :unit_width,
          :unit_type,
          :unit_view
        )
      end

    end
  end
end