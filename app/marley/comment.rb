module Marley

  # = Comments for articles
  # .db file is created in Marley::DATA_DIRECTORY (set in <tt>config.yml</tt>)
  class Comment < ActiveRecord::Base
    
    ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => File.join(DATA_DIRECTORY, 'comments.db') )
    
    belongs_to :post

    validates_presence_of :author, :email, :body, :post_id

    before_create :fix_urls, :check_spam
    
    private

    # See http://railscasts.com/episodes/65-stopping-spam-with-akismet
    def akismet_attributes
      {
        :key                  => CONFIG['typekey_antispam']['key'],
        :blog                 => CONFIG['typekey_antispam']['url'],
        :user_ip              => self.ip,
        :user_agent           => self.user_agent,
        :comment_author       => self.author,
        :comment_author_email => self.email,
        :comment_author_url   => self.url,
        :comment_content      => self.body
      }
    end
    
    # checks if comment isn't spam
    def check_spam
      unless CONFIG['love_spam']
        self.checked = true
        self.spam = !::Antispammer.spam?(akismet_attributes)
        true # return true so it doesn't stop save
      end
    end

    # TODO : Unit test for this
    def fix_urls
      self.url.gsub!(/^(.*)/, 'http://\1') unless self.url =~ %r{^http://} or self.url.empty?
    end
    
  end

end
