class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to house_url(@comment.house.id)
    else
      redirect_to house_url(@comment.house.id)
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    house_id = @comment.house.id
    @comment.destroy
    redirect_to house_url(house_id)
  end

  private
  def comment_params
    params.require(:comment).permit(:body, :house_id)
  end
end
