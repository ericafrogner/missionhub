class SmsKeyword < ActiveRecord::Base  
  SHORT = '75572'
  enforce_schema_rules  
  
  belongs_to :user
  has_many :question_sheets, as: :questionnable
  belongs_to :event, polymorphic: true
  belongs_to :organization
  validates_presence_of :keyword, :explanation, :user_id, :organization_id#, :chartfield
  validates_format_of :keyword, with: /^[\w\d]+$/, on: :create, message: "can't have spaces or punctuation"
  validates_uniqueness_of :keyword, on: :create, case_sensitive: false, message: "must be unique"
  
  state_machine :state, initial: :requested do
    state :requested
    state :active
    state :denied
    state :inactive
    
    event :approve do
      transition requested: :active
    end
    after_transition :on => :approve, :do => :notify_user
    
    event :deny do
      transition requested: :denied
    end
    
    event :disable do
      transition any => :inactive
    end
  end
  
  @queue = :general
  after_create :queue_notify_admin_of_request
  
  def to_s
    keyword
  end
  
  def question_sheet
    @question_sheet ||= question_sheets.last || question_sheets.create!(label: "Keyword #{id}")
  end
  
  def notify_admin_of_request
    KeywordRequestMailer.new_keyword_request(self).deliver
  end
  
  def question_page
    @question_page ||= question_sheet.pages.first || question_sheet.pages.create(number: 1)
  end
  
  def questions
    question_sheet.questions
  end
  
  private
    def queue_notify_admin_of_request
      async(:notify_admin_of_request) 
      true
    end
    
    def notify_user
      if user
        KeywordRequestMailer.notify_user(self).deliver
      end
    end
end
