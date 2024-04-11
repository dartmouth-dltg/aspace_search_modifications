# list out the types of things we want to negate
# with statements like NOT "{type}/{date_like_number}"
AppConfig[:aspace_search_modifications_primary_types] = [
  'accessions',
  'agents/families',
  'agents/corporate_entitites',
  'agents/people',
  'archival_objects',
  'classifications',
  'digital_objects',
  'digital_object_components',
  'locations',
  'objects',
  'resources',
  'record_groups',
  'subjects',
  'top_containers'
]

Rails.application.config.after_initialize do

  class SearchController

    alias_method :pre_aspace_search_mod_search, :search

    def search
      if params[:reset] == 'true' && params[:q] && params[:q].length > 0
        params[:q] = remove_added_custom_params(params)[:q]
      end
      pre_aspace_search_mod_search
    end

  end

  Searchable.module_eval do
    alias_method :pre_aspace_search_mod_set_up_advanced_search, :set_up_advanced_search

    def set_up_advanced_search(default_types = [],default_facets=[],default_search_opts={}, params={})
      params = add_date_like_omissions(params)
      pre_aspace_search_mod_set_up_advanced_search(default_types, default_facets, default_search_opts, params)
    end

    # patched
    def set_search_statement
      rid = defined?(@repo_id) ? @repo_id : nil
  #    Pry::ColorPrinter.pp @search
      l = @search[:limit].blank? ? 'all' : @search[:limit]
      type = "<strong> #{I18n.t("search-limits.#{l}")}</strong>"
      type += I18n.t('search_results.in_repository', :name => CGI::escapeHTML(get_pretty_facet_value('repository', "/repositories/#{rid}"))) if rid
  
      Rails.logger.debug("TYPE: #{type}")
      condition = " "
      @search[:q].each_with_index do |q, i|
        # patch by skipping all added search statements
        next if i >= @search_length
        # end patch
        condition += '<li>'
        if i == 0
          if !@search[:op][i].blank?
            condition += I18n.t("search_results.op_first_row.#{@search[:op][i]}", :default => "").downcase
          end
        else
          condition += I18n.t("search_results.op.#{@search[:op][i]}", :default => "").downcase
        end
        f = @search[:field][i].blank? ? 'keyword' : @search[:field][i]
        condition += ' ' + I18n.t("search_results.#{f}_contain", :kw => CGI::escapeHTML((q == '*' ? I18n.t('search_results.anything') : q)) )
        unless @search[:from_year][i].blank? && @search[:to_year][i].blank?
          from_year = @search[:from_year][i].blank? ? I18n.t('search_results.filter.year_begin') : @search[:from_year][i]
          to_year = @search[:to_year][i].blank? ? I18n.t('search_results.filter.year_now') : @search[:to_year][i]
          condition += ' ' + I18n.t('search_results.filter.from_to', :begin => "<strong>#{from_year}</strong>", :end => "<strong>#{to_year}</strong>")
        end
        condition += '</li>'
        Rails.logger.debug("Condition: #{condition}")
      end
      @search[:search_statement] = I18n.t('search_results.search_for', :type => type,
                                          :conditions => "<ul class='no-bullets'>#{condition}</ul>")
    end

    def remove_added_custom_params(params)
      indices_to_remove = []

      AppConfig[:aspace_search_modifications_primary_types].each do |type|
        params[:q].each_with_index do |query, idx|
          if query.include?('NOT "' + type + '/')
            indices_to_remove << idx
          end
        end
      end
  
      params[:q] = params[:q].delete_if.with_index{|_, i| indices_to_remove.include?(i) }
      params[:op] = params[:op].delete_if.with_index{|_, i| indices_to_remove.include?(i) }
  
      params
    end
  
    def add_date_like_omissions(params)
      primary_types = AppConfig[:aspace_search_modifications_primary_types]

      params = remove_added_custom_params(params)

      @search_length = params[:q].length

      # basic regex for dates that can be by themselves or have a quote on one side or the other
      potential_dates = params[:q].map{ |d| " " + d + " "}.join.scan(/\s+"*(\d{4})"*\s+/).flatten

      # add the negations to the query
      primary_types.each_with_index do |type|
        potential_dates.each_with_index do |date|
          params[:q] << 'NOT "' + type + '/' + date.squish + '"'
          params[:op] << "AND"
        end
      end

      params
    end

  end
end
