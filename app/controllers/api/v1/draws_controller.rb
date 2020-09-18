module Api
  module V1
    class DrawsController < ApplicationController
      before_action :authorize_user!

      def show
        draw_mgr = get_draw_manager(params[:draw])
        if draw_mgr.valid?
          structure = draw_mgr.draw_structure
          render json: structure
        else
          render json: draw_mgr.errors, status: :unprocessable_entity
        end
      end

      def create
        draw_mgr = get_draw_manager(params[:draw])
        draw_mgr.draw
        if draw_mgr.valid?
          render json: params[:draw], status: :created
        else
          render json: draw_mgr.errors, status: :unprocessable_entity
        end
      end

      def destroy
        draw_mgr = get_draw_manager
        draw_mgr.delete_draw(@contest)
      end

      private

      def get_draw_manager(myparams = {})
        dmclass = "DrawManager#{@contest.ctype}"
        dmclass.constantize.new(@contest, myparams)
      end

      # NOT USED: draw_tableau cannot be permitted as array of arrays
      # def draw_params
      #   params.require(:draw).permit( { draw_seeds: [] },
      #                                 { draw_tableau: [] } )
      # end

    end
  end
end
