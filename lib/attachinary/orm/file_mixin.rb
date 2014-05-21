module Attachinary
  module FileMixin
    def self.included(base)
      base.validates :public_id, :version, :resource_type, presence: true
      if Rails::VERSION::MAJOR == 3
        base.attr_accessible *Attachinary.permitted_fields
      end
      base.after_destroy :destroy_file
      base.after_create  :remove_temporary_tag
    end

    def as_json(options)
      super(only: [:id, :public_id, :format, :version, :resource_type] + Attachinary.extra_fields, methods: [:path])
    end

    def as_form_json
      data = {
        public_id: public_id,
        version: version,
        format: "jpeg",
        crop: 'fill',
        width: 75,
        height: 75
      }
      Attachinary.extra_fields.each do |field|
        data[field] = self.send(field)
      end
      data.as_json
    end

    def path(custom_format=nil)
      p = "v#{version}/#{public_id}"
      if resource_type == 'image' && custom_format != false
        custom_format ||= format
        p<< ".#{custom_format}"
      end
      p
    end

    def fullpath(options={})
      format = options.delete(:format)
      Cloudinary::Utils.cloudinary_url(path(format), options.reverse_merge(:resource_type => resource_type))
    end
    
  protected
    def keep_remote?
      Cloudinary.config.attachinary_keep_remote == true
    end
    
  private
    def destroy_file
      Cloudinary::Uploader.destroy(public_id) if public_id && !keep_remote?
    end

    def remove_temporary_tag
      Cloudinary::Uploader.remove_tag(Attachinary::TMPTAG, [public_id]) if public_id
    end

  end
end
