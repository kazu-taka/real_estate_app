class HousesController < ApplicationController
  def index
    @houses = House.all
  end

  def show
    @house = House.find(params[:id])
  end

  def new
    @house = House.new
  end

  def create
    @house = House.new(house_params)
    @house.save
    redirect_to @house
  end

  def edit
    @house = House.find(params[:id])
  end

  def update
  end

  def destroy
  end

  private
  def house_params
    params.require(:house).permit(:name, :price, :address, :note)
  end
end
