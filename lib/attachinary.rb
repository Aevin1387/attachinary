require 'attachinary/engine'

module Attachinary
  TMPTAG = "attachinary_tmp"
  FIELDS = [:public_id, :version, :width, :height, :format, :resource_type]

  mattr_accessor :extra_fields
  @@extra_fields = []

  def self.setup
    yield self
  end

  def self.permitted_fields
    (FIELDS + self.extra_fields).flatten
  end
end
