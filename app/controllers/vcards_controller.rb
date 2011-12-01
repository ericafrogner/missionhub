require 'vpim/book'

class VcardsController < ApplicationController

  def create
     VcardMailer.enqueue.vcard(params[:email], params[:person_id])

     render nothing: true      
  end

  def bulk_create

    ids = params[:ids].split(',')

    if ids.size
      book = Vpim::Book.new
      Person.includes(:current_address, :primary_phone_number, :primary_email_address).find(ids).each do |person|
       book << person.vcard
      end

      respond_to do |wants|
        wants.html do
          if params.has_key?(:email)
            VcardMailer.enqueue.bulk_vcard(params[:email],  book)
            render nothing: true
          else
            send_data book, :type => 'application/vcard', :disposition => 'attachment', :filename => "contacts.vcf"
          end
        end
      end
    end

  end

end