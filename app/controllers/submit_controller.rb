class SubmitController < ApplicationController
    before_action :set_submit, only: [:show, :edit, :update, :destroy]
  
    # GET /submit
    # GET /submit.json
    def index
      @submit = Submit.all
    end
  
    # GET /submit/1
    # GET /submit/1.json
    def show
    end
  
    # GET /submit/new
    def new
      @submit = Submit.new
    end
  
    # GET /submit/1/edit
    def edit
    end
  
    # POST /submit
    # POST /submit.json
    def create
      @submit = Submit.new(submit_params)
  
      respond_to do |format|
        if @submit.save
          format.html { redirect_to @submit, notice: 'Post was successfully created.' }
          format.json { render :show, status: :created, location: @submit }
        else
          format.html { render :new }
          format.json { render json: @submit.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /submit/1
    # PATCH/PUT /submit/1.json
    def update
      respond_to do |format|
        if @submit.update(submit_params)
          format.html { redirect_to @submit, notice: 'Post was successfully updated.' }
          format.json { render :show, status: :ok, location: @submit }
        else
          format.html { render :edit }
          format.json { render json: @submit.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /submit/1
    # DELETE /submit/1.json
    def destroy
      @user.destroy
      respond_to do |format|
        format.html { redirect_to submit_url, notice: 'Post was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_submit
        @submit = Submit.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def submit_params
        params.require(:submit).permit(:title, :url)
      end
  end
  