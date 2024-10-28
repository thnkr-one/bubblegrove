# app/jobs/image_attachment_job.rb

require 'open-uri'

class ImageAttachmentJob < ApplicationJob
  queue_as :default

  def perform(class_name, record_id, image_url)
    return unless record_id.present? && image_url.present?

    begin
      record = class_name.constantize.find(record_id)

      # Use 'images' since 'ThnkVariant' has 'has_many_attached :images'
      record.images.attach(
        io: URI.open(image_url),
        filename: File.basename(URI.parse(image_url).path)
      )
      Rails.logger.info("Image attached successfully to #{class_name} ID: #{record_id}")
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("#{class_name} with ID #{record_id} not found: #{e.message}")
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Failed to open image URL for #{class_name} ID #{record_id}: #{e.message}")
    rescue => e
      Rails.logger.error("Failed to attach image to #{class_name} ID #{record_id}: #{e.message}")
    end
  end
end
