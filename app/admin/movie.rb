ActiveAdmin.register Movie do


  index do
    column :id
    column "Poster" do |m|
      if m.thumbnail_image_raw?
        "<div align='center'>
          <img style='border:1px solid black' src='data:image/png;base64,#{Base64.encode64(m.thumbnail_image_raw)}' />
        </div>".html_safe
      else
        "-"
      end
    end
    column "Title", :sortable => :title do |m|
      content_tag :strong, m.title
    end
    column raw("&hearts;"), :sortable => :rating, :align => :right do |m|
      m.rating.round(1)
    end
    column("Size", :sortable => :bytes) do |m|
      size = m.bytes.nil? ? "?" : number_to_human_size(m.bytes.to_i, :precision => 2)
      content_tag :nobr, size
    end
    column "Runtime", :sortable => :runtime do |m|
      hours = (m.runtime.to_f / 60.00).round(2)
      "%s Hour%s" % [hours.to_s, (hours > 1) ? "s" : " "]
    end
    column "Rating", :certification
    column "Released", :release_date

    column "Path", :sortable => :path do |m|
      link_to("Source", admin_movie_source_path(m.movie_source_id)) + "/" + Pathname.new(m.directory.basename.join(m.pathname.basename)).to_path
    end

    actions :defaults => false do |m|
      link_to "IMDb", "http://www.imdb.com/title/#{m.imdb_id}", :target => "_blank"
    end
  end

end
