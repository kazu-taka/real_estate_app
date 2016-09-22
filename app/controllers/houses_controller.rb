class HousesController < ApplicationController
  before_action :set_house, only: [:show, :edit, :update, :destroy]

  def index
    @houses = House.all
  end

  def show
  end

  def new
    @house = House.new
  end

  def create
    @house = House.new(house_params)
    if @house.save
      redirect_to @house
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @house.update(house_params)
      redirect_to @house
    else
      render :edit
    end
  end

  def destroy
    @house.destroy
    redirect_to root_path
  end

  private
  def house_params
    params.require(:house).permit(:name, :price, :address, :note)
  end

  def set_house
    @house = House.find(params[:id])
  end
end
