require 'sinatra'
require 'data_mapper'
require 'slim'
require 'sass'
require 'coffee-script'
# require 'rdiscount'


# TODO
# ----------------------------

# Config
# ----------------------------
set :slim, :pretty => true
# Page = Struct.new(:slug, :text, :description)
before do
  # @recent_posts = Post.all(:fields => [:slug, :title, :published], :order => [:published.desc], :limit => 3)
  # @pages = Page.all(:fields => [:title, :slug, :description], :order => [:position.asc])
  @pages = Page.all(:slug.not => 'home', :fields => [:title, :slug, :description], :order => [:position.asc])
  # @pages = pages.
  # @pages = [
  #   # Page.new('/','Home',''),
  #   Page.new('money-topics','Money Topics','A little rollover subhead here.'),
  #   Page.new('education','Education','A little rollover subhead here.'),
  #   Page.new('how-do-i','How do I?','A little rollover subhead here.'),
  #   Page.new('multimedia','Multimedia','A little rollover subhead here.'),
  #   Page.new('assistance','Assistance','A little rollover subhead here.'),
  #   Page.new('connect','Connect with us.','A little rollover subhead here.'),
  # ]
end


# Models
# ----------------------------
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://root:@127.0.0.1/sinatra_gvllib')

class Page
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true #, :unique => true
  property :slug, String, :default => lambda { |r,p| r.slugize }
  property :description, String, :length => 255
  # property :description, Text
  property :body, Text, :required => true
  property :position, Integer
  
  def slugize; self.title.downcase.gsub(/\W/,'-').squeeze('-').chomp('-') end
  def path; "/#{self.slug}" end

  has n, :sections
  has n, :links
end

class Section
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true
  property :slug, String, :default => lambda { |r,p| r.slugize }
  property :position, Integer, :default => lambda { |r,p| r.next_position }

  def slugize; self.title.downcase.gsub(/\W/,'-').squeeze('-').chomp('-') end
  def next_position; (last = Section.first(:page_id => self.page_id, :order => [:position.desc])) ? last.position + 1 : 1 end

  has n, :links
  belongs_to :page
end

class Link
  include DataMapper::Resource
  property :id, Serial
  property :text, String, :required => true
  property :url, String, :required => true
  property :position, Integer, :default => lambda { |r,p| r.next_position }

  def next_position; (last = Link.first(:page_id => self.page_id, :order => [:position.desc])) ? last.position + 1 : 1 end

  belongs_to :page
  belongs_to :section
end

DataMapper.finalize
DataMapper.auto_upgrade!
# DataMapper.auto_migrate!


# Helpers
# ----------------------------
helpers do
  # def markdown(md) RDiscount.new(md, :smart).to_html end
  def truncate(text, length = 40, end_string = ' &hellip;')
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end
  def protected!
    if ENV['RACK_ENV'] == 'production'
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      unless @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['ADMIN_USERNAME'], ENV['ADMIN_PASSWORD']]
        response['WWW-Authenticate'] = %(Basic realm='Administration')
        throw(:halt, [401, "Not authorized\n"])
      end
    end
  end
  def get_title
    if defined?(@page)
      @page.title
    elsif defined?(@title)
      @title
    else
      ''
    end
  end
  def page_class; request.path.split('/')[1] end
  def nav_class(uri)
    segments = request.path.split('/')
    if segments.include?(uri)
      'current'
    end
  end

end


# Routes
# ----------------------------
get('/css/screen.css') { scss(:'assets/screen') }
get('/css/admin.css') { scss(:'assets/admin') }
get('/js/admin.js') { coffee(:'assets/admin') }

get '/' do
  @page = Page.first(:slug => 'home')
  slim :index
end

get '/admin' do
  protected!
  # @page = Page.first(:slug => 'home')
  slim :'admin/index', :layout => :'admin/layout'
end
get '/admin/pages' do
  protected!
  @pages = Page.all(:order => [:position.asc])
  slim :'admin/pages/index', :layout => :'admin/layout'
end
get '/admin/pages/:id' do
  protected!
  @page = Page.get(params[:id])
  slim :'admin/pages/detail', :layout => :'admin/layout'
end
get '/admin/pages/:id/edit' do
  protected!
  @page = Page.get(params[:id])
  slim :'admin/pages/form', :layout => :'admin/layout'
end
patch '/admin/pages/:id' do
  protected!
  @page = Page.get(params[:id])
  @page.attributes = params['page']
  if @page.save
    redirect to("/admin/pages/#{@page.id}")
  else
    slim :'admin/pages/form', :layout => :'admin/layout'
  end
end
put '/admin/pages/sort' do
  protected!
  params[:pages].each_with_index do |id, i|
    Faq.update_all(['position=?', i+1], ['id=?', id])
  end
  # render :nothing => true
  ''
end

get '/:slug' do
  # if @page = Page.first(:slug => params[:slug])
  if params[:slug] != 'home' && @page = Page.first(:slug => params[:slug])
    slim :page
  else
    error 404
  end
end

# get '/blog' do
#   @title = 'Blog'
#   @posts = Post.all(:order => [:published.desc])
#   slim :'posts/index'
# end
# get '/blog/archive' do
#   @title = 'Archive'
#   @post_groups = Post.all.inject({}) do |s,p|
#     ym = p.published.strftime('%Y-%m')
#     s.merge(s[ym] ? {ym=>s[ym]<<p} : {ym=>[p]})
#   end.sort {|a,b| b[0] <=> a[0]}
#   slim :'posts/archive'
# end
# get '/blog/new' do
#   protected!
#   @title = 'New Post'
#   @post = Post.new
#   slim :'posts/form', locals: { new_record: true }
# end
# post '/blog' do
#   protected!
#   @post = Post.new(params['post'])
#   if @post.save
#     redirect to('/blog/' + @post.slug)
#   else
#     @title = 'New Post'
#     slim :'posts/form', locals: { new_record: true }
#   end
# end
# get '/blog/:id/edit' do
#   protected!
#   if @post = Post.get(params[:id])
#     @title = 'Edit Post'
#     slim :'posts/form', locals: { new_record: false }
#   else
#     error 404
#   end
# end
# patch '/blog/:id' do
#   protected!
#   @post = Post.get(params[:id])
#   @post.attributes = params['post']
#   if @post.save
#     redirect to('/blog/' + @post.slug)
#   else
#     @title = 'Edit Post'
#     slim :'posts/form', locals: { new_record: false }
#   end
# end
# delete '/blog/:id' do
#   protected!
#   Post.get(params[:id]).destroy
#   redirect to('/blog')
# end
# get '/blog/:slug' do
#   if @post = Post.first(:slug => params[:slug])
#     @title = @post.title
#     @older_post = Post.first(:published.lt => @post.published, :order => [:published.desc])
#     @newer_post = Post.first(:published.gt => @post.published, :order => [:published.asc])
#     slim :'posts/detail'
#   else
#     error 404
#   end
# end

error 404 do
  @title = 'Not Found'
  slim :'404'
end
