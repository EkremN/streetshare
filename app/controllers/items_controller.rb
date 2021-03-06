class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    if params[:search].nil?
      #@Items = @items_paginator.group_by { |r| r.created_at.to_date }
      @users = User.all
      @items = Item.where(user: @users)
      @items_paginator = @items.order(created_at: :desc).page(params[:page])
      @markers = @items_paginator.map do |item|
        {
          lat: item.user.latitude,
          lng: item.user.longitude,
          infoWindow: render_to_string(partial: "map_box", locals: { user: item.user })
        }
      end
    elsif params[:search][:query].present? && params[:search][:location].present?

      @items_paginator = Item.search_by_title_address(params[:search][:query]).page(params[:page])

      @users = User.near(params[:search][:location]).to_a
      # @items = @users.map(&:items).flatten
      @items = @items_paginator.where(user: @users)
      # @items = policy_scope(item)
      # @items = @items.search_by_title_and_model(params[:search]) if params[:search].present?
      # @items = item.geocoded #returns flats with coordinates

      @markers = @items.map do |item|
        {
          lat: item.user.latitude,
          lng: item.user.longitude,
          infoWindow: render_to_string(partial: "map_box", locals: { user: item.user })
          # image_url: helpers.asset_url('item.png')
        }
      end
      # raise
    else
      flash[:notice] = 'Please fill all the fields'
      redirect_to root_path
    end
  end

  def show
    @order = Order.new
    @review = Review.new
    @item = Item.find(params[:id])
    @markers = [ {
          lat: @item.user.latitude,
          lng: @item.user.longitude,
          infoWindow: render_to_string(partial: "map_box", locals: { user: @item.user })
          # image_url: helpers.asset_url('item.png')
        }]
    # authorize @item
  end

  def edit
    # authorize @item
  end

  def new
    @item = Item.new
    # authorize @item
  end

  def update
    @item.update(item_params)
    redirect_to item_path(@item)
    # authorize @item
  end

  def create
    @item = Item.new(item_params)
    @item.user = current_user
    if @item.save
      redirect_to item_path(@item)
    else
      render :new
    end
    # authorize @item
  end

  def destroy
    @item.destroy
    redirect_to items_path
    # authorize @item
  end

  private

  def item_params
    params.require(:item).permit(:title, :description, :photo, :photo_cache, :address, :price, :category_id)
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
