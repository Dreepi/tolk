module Tolk
  class LocalesController < Tolk::ApplicationController
    before_filter :find_locale, :only => [:show, :all, :update, :updated]
    before_filter :ensure_no_primary_locale, :only => [:all, :update, :show, :updated]
    before_filter :ensure_authorized_for_locale, :only => [:update]
    before_filter :ensure_authorized_to_create_locale?, :only => [:create]

    def index
      @locales = Tolk::Locale.secondary_locales
      @primary_key_scopes = Tolk::Phrase.all(:order => 'tolk_phrases.key ASC').collect{|phrase| phrase.key.split('.').first}.uniq
    end

    def show
      respond_to do |format|
        format.html do
          @phrases = @locale.phrases_without_translation(params[:page])
        end
        format.atom { @phrases = @locale.phrases_without_translation(params[:page], :per_page => 50) }
        format.yaml { render :text => @locale.to_hash.ya2yaml(:syck_compatible => true) }
      end
    end

    def update
      @locale.translations_attributes = params[:translations]
      @locale.save
      redirect_to request.referrer
    end

    def all
      @phrases = @locale.phrases_with_translation(params[:page])
    end

    def updated
      @phrases = @locale.phrases_with_updated_translation(params[:page])
      render :all
    end

    def create
      Tolk::Locale.create!(params[:tolk_locale])
      redirect_to :action => :index
    end

    private

    def find_locale
      @locale = Tolk::Locale.find_by_name!(params[:id])
    end
  end
end
