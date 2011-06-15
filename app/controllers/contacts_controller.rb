class ContactsController < ApplicationController
  before_filter :get_person
  before_filter :get_keyword, :only => [:new, :update, :thanks]
  
  def index
    @organization = Organization.find_by_id(params[:org_id])
    @organization ||= current_person.organizations.first
    unless @organization
      redirect_to user_root_path, :error => t('ma.contacts.index.which_org')
      return false
    end
    @question_sheets = @organization.question_sheets
    @questions = @organization.questions.where("#{PageElement.table_name}.hidden" => false).flatten.uniq
    @hidden_questions = @organization.questions.where("#{PageElement.table_name}.hidden" => true).flatten.uniq
    if params[:assigned_to]
      if params[:assigned_to] == 'all'
        @people = @organization.contacts.order('lastName, firstName')
      else
        @assigned_to = Person.find(params[:assigned_to])
        @people = Person.order('lastName, firstName').includes(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
      end
    else
      @people = unassigned_people(@organization)
    end
  end
  
  def new
    if params[:received_sms_id]
      sms = ReceivedSms.find_by_id(Base62.decode(params[:received_sms_id])) 
      if sms
        @keyword ||= SmsKeyword.where(:keyword => sms.message).first
        @person.phone_numbers.create!(:number => sms.phone_number, :location => 'mobile') unless @person.phone_numbers.detect {|p| p.number_with_country_code == sms.phone_number}
        sms.update_attribute(:person_id, @person.id) unless sms.person_id
      end
    end
    get_answer_sheet(@keyword, @person)
  end
    
  def update
    get_answer_sheet(@keyword, @person)
    @person.update_attributes(params[:person]) if params[:person]
    question_set = QuestionSet.new(@keyword.questions, @answer_sheet)
    question_set.post(params[:answers], @answer_sheet)
    question_set.save
    # Make them a contact of the org associated with this keyword
    unless OrganizationMembership.find_by_person_id_and_organization_id(@person.id, @keyword.organization.id)
      OrganizationMembership.create!(:person_id => @person.id, :organization_id => @keyword.organization.id, :role => 'contact') 
    end
    if @person.valid?
      render :thanks
    else
      render :new
    end
  end
  
  def thanks
  end
  
  protected
    
    def get_keyword
      @keyword = SmsKeyword.where(:keyword => params[:keyword]).first if params[:keyword]
    end
    
    def get_person
      @person = current_user.person
    end
end
