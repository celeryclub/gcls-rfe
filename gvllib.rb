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

  has n, :sections, :order => [:position.asc]
  has n, :links, :order => [:position.asc]
end

class Section
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true
  property :slug, String, :default => lambda { |r,p| r.slugize }
  property :position, Integer, :default => lambda { |r,p| r.next_position }

  def slugize; self.title.downcase.gsub(/\W/,'-').squeeze('-').chomp('-') end
  def next_position; (last = Section.first(:page_id => self.page_id, :order => [:position.desc])) ? last.position + 1 : 1 end

  has n, :links, :order => [:position.asc]
  belongs_to :page
end

class Link
  include DataMapper::Resource
  property :id, Serial
  property :text, String, :length => 255, :required => true
  property :url, String, :length => 255, :required => true
  property :position, Integer, :default => lambda { |r,p| r.next_position }

  def next_position; (last = Link.first(:page_id => self.page_id, :order => [:position.desc])) ? last.position + 1 : 1 end

  belongs_to :page
  belongs_to :section, :required => false
end

DataMapper.finalize
DataMapper.auto_upgrade!
# DataMapper.auto_migrate!


# Helpers
# ----------------------------
helpers do
  # def markdown(md) RDiscount.new(md, :smart).to_html end
  def truncate(text, length = 40, end_string = '&hellip;')
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
  # @pages = Page.all(:fields => [:id, :title, :description, :body], :order => [:position.asc])
  @pages = Page.all(:order => [:position.asc])
  slim :'admin/pages/index', :layout => :'admin/layout'
end
# get '/admin/pages/:id' do
#   protected!
#   @page = Page.get(params[:id])
#   slim :'admin/pages/detail', :layout => :'admin/layout'
# end
get '/admin/pages/:id/edit' do
  protected!
  @page = Page.get(params[:id])
  slim :'admin/pages/form', :layout => :'admin/layout'
end
patch '/admin/pages/:id' do
  protected!
  @page = Page.get(params[:id])
  @page.attributes = params[:page]
  if @page.save
    # redirect to("/admin/pages/#{@page.id}")
    # @notice = 'Page updated successfully'
    redirect to('/admin/pages')
  else
    slim :'admin/pages/form', :layout => :'admin/layout'
  end
end
put '/admin/pages/sort' do
  protected!
  # order = params[:page]
  # Page.update_all(['position = FIND_IN_SET(id, ?)', ids.join(',')], { :id => ids })
  params[:page].each_with_index do |id, i|
    # Page.update_all(['position=?', i+1], ['id=?', id])
    # Page.update(:login => 'kintaro')
    Page.get(id).update(:position => i+1)
  end
  # render :nothing => true
  ''
  # params[:page].inspect
end
get '/admin/links' do
  protected!
  # @links = Link.all(:order => [:position.asc])
  @pages = Page.all(:order => [:position.asc])
  slim :'admin/links/index', :layout => :'admin/layout'
end
get '/admin/links/new' do
  protected!
  @link = Link.new
  slim :'admin/links/form', :layout => :'admin/layout', :locals => { new_record: true }
  # "Hello #{@link.inspect}"
end
post '/admin/links' do
  protected!
  @link = Link.new(params[:link])
  if @link.save
    redirect to('/admin/links')
  else
    slim :'admin/links/form', :layout => :'admin/layout', :locals => { new_record: true }
  end
end
get '/admin/links/:id/edit' do
  protected!
  @link = Link.get(params[:id])
  slim :'admin/links/form', :layout => :'admin/layout', :locals => { new_record: false }
end
patch '/admin/links/:id' do
  protected!
  @link = Link.get(params[:id])
  @link.attributes = params[:link]
  if @link.save
    redirect to('/admin/links')
  else
    slim :'admin/links/form', :layout => :'admin/layout', :locals => { new_record: false }
  end
end
delete '/admin/links/:id' do
  protected!
  Link.get(params[:id]).destroy
  redirect to('/admin/links')
end
put '/admin/links/sort' do
  protected!
  params[:link].each_with_index do |id, i|
    Link.get(id).update(:position => i+1)
  end
  ''
end

get '/:slug' do
  pass if params[:slug] == 'home'
  # if params[:slug] != 'home' && @page = Page.first(:slug => params[:slug])
  if @page = Page.first(:slug => params[:slug])
    slim :page
  else
    error 404
  end
end

error 404 do
  @title = 'Not Found'
  slim :'404'
end
