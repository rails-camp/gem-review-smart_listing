class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
    scope = Movie.all
    options = {}
    options = options.merge(query: params[:filter]) if params[:filter].present?
    options = options.merge(filters: params[:f]) if params[:f].present?
    scope = Movie.all_with_filter(options, scope)

    if params[:movies_smart_listing] && params[:movies_smart_listing][:page].blank?
      params[:movies_smart_listing][:page] = 1
    end

    @movies = smart_listing_create :movies, scope, partial: "movies/list", page_sizes: [10, 25, 50, 100, 250, 500]
  end

  def show
    respond_to do |format|
      format.json { render json: @movie }
    end
  end

  def new
    @movie = Movie.new
  end

  def edit
  end

  def create
    @movie = Movie.create(movie_params)
  end

  def update
    @movie.update_attributes(movie_params)
  end

  def destroy
    @movie.destroy
  end

  def search
    render json: Movie.where("LOWER(title) LIKE LOWER(?)", "%#{params[:q]}%")
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def movie_params
      params.require(:movie).permit(:title, :director)
    end
end
