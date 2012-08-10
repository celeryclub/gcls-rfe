# encoding: utf-8
# the above is a fix for multiline entries with Structs

require 'sinatra'
require 'sinatra/flash'
require 'data_mapper'
require 'slim'
require 'sass'
require 'coffee-script'


# TODO
# ----------------------------
# fix scrolling on form pages?
# Redirects
# Crop big-ring.png?


# Config
# ----------------------------
enable :sessions
set :slim, :pretty => true
Branch = Struct.new(:name, :url, :address, :phone, :hours)
before do
  @pages = Page.all(:slug.not => 'home', :fields => [:title, :slug, :description], :order => [:position.asc])
  @branches = [
    Branch.new('Hughes Main Library', 'http://www.greenvillelibrary.org/index.php/Main.html', "25 Heritage Green Place\r\n Greenville, SC 29601-2034", '864-242-5000', "M-F 9:00A-9:00P\r\n Sat 9:00A-6:00P \r\nSun 2:00P-6:00P"),
    Branch.new('Anderson Road (West Branch)', 'http://www.greenvillelibrary.org/index.php/Anderson-Road.html', "2625 Anderson Rd\r\n Greenville, SC 29611", '864-269-5210', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Augusta Road  (Ramsey Family Branch)', 'http://www.greenvillelibrary.org/index.php/Augusta-Road.html', "100 Lydia St\r\n Greenville, SC 29605", '864-277-0161', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Berea ( Sarah Dobey Jones Branch)', 'http://www.greenvillelibrary.org/index.php/Berea.html', "111 N. Hwy. 25 Byp\r\n Greenville, SC 29617", '864-246-1695', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Fountain Inn  (Kerry Ann Younts - Culp Branch)', 'http://www.greenvillelibrary.org/index.php/Fountain-Inn.html', "311 North Main St\r\n Fountain Inn, SC 29644", '864-862-2576', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Greer ( Jean M. Smith Branch)', 'http://www.greenvillelibrary.org/index.php/Greer.html', "505 Pennsylvania Ave\r\n Greer, SC 29650", '864-877-8722', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Mauldin  (W. Jack Greer Branch)', 'http://www.greenvillelibrary.org/index.php/Mauldin.html', "800 West Butler Rd\r\n Greenville, SC 29607", '864-277-7397', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Pelham Road  (F.W Symmes Branch)', 'http://www.greenvillelibrary.org/index.php/Pelham-Road.html', "1508 Pelham Rd\r\n Greenville, SC 29615", '864-288-6688', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Simpsonville  (Hendricks Branch)', 'http://www.greenvillelibrary.org/index.php/Simpsonville.html', "626 NE Main St\r\n Simpsonville, SC 29681", '864-963-9031', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Taylors ( Burdette Branch)', 'http://www.greenvillelibrary.org/index.php/Taylors.html', "316 W. Main St\r\n Taylors, SC 29687", '864-268-5955', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P"),
    Branch.new('Travelers Rest ( Sargent Branch)', 'http://www.greenvillelibrary.org/index.php/Travelers-Rest.html', "17 Center St\r\n Travelers Rest, SC 29690", '864-834-3650', "M-Th 9:00A-9:00P \r\nF-Sat 9:00A-6:00P")
  ]
end


# Models
# ----------------------------
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://root:@127.0.0.1/sinatra_rfe')

class Page
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true #, :unique => true
  property :slug, String
  property :description, String, :length => 255
  # property :description, Text
  property :body, Text, :required => true
  property :position, Integer

  has n, :sections, :order => [:position.asc]
  has n, :links, :order => [:position.asc]

  def path; "/#{self.slug}" end
  def self.assignables(options = {})
    self.all({:slug.not => ['home', 'connect']}.merge(options))
  end
  def unsectioned_links
    self.links.select { |link| !link.section_id }
  end
end

class Section
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true
  property :position, Integer, :default => lambda { |r,p| r.next_position }

  has n, :links, :order => [:position.asc], :constraint => :set_nil
  belongs_to :page

  before :valid?, :fix_association_errors

  def next_position
    (last = Section.first(:page_id => self.page_id, :order => [:position.desc])) ? last.position + 1 : 1
  end
  def fix_association_errors
    if self.page_id.class == String then self.page_id = nil end
  end
end

class Link
  include DataMapper::Resource
  property :id, Serial
  property :url, String, :length => 255, :required => true
  property :text, String, :length => 255 #, :required => true
  property :description, String, :length => 255
  property :position, Integer, :default => lambda { |r,p| r.next_position }

  belongs_to :page
  belongs_to :section, :required => false

  before :valid?, :fix_association_errors

  # def url= new_url
  #   # super new_url.downcase
  #   unless new_url =~ %r{^http:\/\/.*}
  #     new_url = "http://#{new_url}"
  #   end
  #   super new_url
  # end
  def absolute_url
    (self.url =~ %r{^http:\/\/.*}) ? self.url : "http://#{self.url}"
  end
  def text_or_absolute_url
    (self.text && !self.text.empty?) ? self.text : self.absolute_url
  end
  def next_position
    (last = Link.first(:page_id => self.page_id, :order => [:position.desc])) ? last.position + 1 : 1
  end
  def fix_association_errors
    [:page_id, :section_id].each do |property|
      if self.send(property).class == String then self.send("#{property}=",nil) end
    end
  end
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
    if defined?(@page.title)
      @page.title
    elsif defined?(@title)
      @title
    else
      ''
    end
  end
  # def home?; request.path.split('/').length == 0 end
  def page_class; request.path.split('/')[1] end
  def is_current?(slug)
  # def nav_class(uri)
    if slug == 'home'
      request.path.split('/').length == 0
    else
      request.path.split('/').include?(slug)
    end
    # segments = request.path.split('/')
    # if segments.include?(uri)
      # 'current'
    # end
  end
end


# Routes
# ----------------------------
get('/css/screen.css') { scss(:'assets/screen') }
# get('/css/bootstrap-custom.css') { less(:'assets/bootstrap/bootstrap') }
get('/css/admin.css') { scss(:'assets/admin') }
get('/js/admin.js') { coffee(:'assets/admin') }

get '/' do
  @all_nav = true
  @page = Page.first(:slug => 'home')
  slim :index
end

get '/admin' do
  protected!
  @pages = Page.all(:order => [:position.asc])
  slim :'admin/index', :layout => :'admin/layout'
end
get '/admin/pages/:id/edit' do
  protected!
  @page = Page.get(params[:id])
  slim :'admin/page_form', :layout => :'admin/layout'
end
patch '/admin/pages/:id' do
  protected!
  @page = Page.get(params[:id])
  @page.attributes = params[:page]
  if @page.save
    flash[:alert] = 'Page updated successfully'
    redirect to('/admin')
  else
    slim :'admin/page_form', :layout => :'admin/layout'
  end
end
put '/admin/pages/sort' do
  protected!
  params[:page].each_with_index do |id, i|
    Page.get(id).update(:position => i+1)
  end
  ''
end
get '/admin/sections/new' do
  protected!
  @section = Section.new
  slim :'admin/section_form', :layout => :'admin/layout'
end
post '/admin/sections' do
  protected!
  @section = Section.new(params[:section])
  if @section.save
    flash[:alert] = 'Section created successfully'
    redirect to('/admin')
  else
    slim :'admin/section_form', :layout => :'admin/layout'
  end
end
get '/admin/sections/:id/edit' do
  protected!
  @section = Section.get(params[:id])
  slim :'admin/section_form', :layout => :'admin/layout'
end
patch '/admin/sections/:id' do
  protected!
  @section = Section.get(params[:id])
  @section.attributes = params[:section]
  if @section.save
    flash[:alert] = 'Section updated successfully'
    redirect to('/admin')
  else
    slim :'admin/section_form', :layout => :'admin/layout'
  end
end
delete '/admin/sections/:id' do
  protected!
  Section.get(params[:id]).destroy
  flash[:alert] = 'Section deleted successfully'
  redirect to('/admin')
end
put '/admin/sections/sort' do
  protected!
  params[:section].each_with_index do |id, i|
    Section.get(id).update(:position => i+1)
  end
  ''
end
get '/admin/links/new' do
  protected!
  @link = Link.new
  slim :'admin/link_form', :layout => :'admin/layout'
end
post '/admin/links' do
  protected!
  @link = Link.new(params[:link])
  if @link.save
    flash[:alert] = 'Link created successfully'
    redirect to('/admin')
  else
    slim :'admin/link_form', :layout => :'admin/layout'
  end
end
get '/admin/links/:id/edit' do
  protected!
  @link = Link.get(params[:id])
  slim :'admin/link_form', :layout => :'admin/layout'
end
patch '/admin/links/:id' do
  protected!
  @link = Link.get(params[:id])
  @link.attributes = params[:link]
  if @link.save
    flash[:alert] = 'Link updated successfully'
    redirect to('/admin')
  else
    slim :'admin/link_form', :layout => :'admin/layout'
  end
end
delete '/admin/links/:id' do
  protected!
  Link.get(params[:id]).destroy
  flash[:alert] = 'Link deleted successfully'
  redirect to('/admin')
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
  if @page = Page.first(:slug => params[:slug])
    slim :page
    # @page.inspect
  else
    error 404
    # halt 404
  end
end

error 404 do
  @all_nav = true
  @title = 'Not Found'
  slim :'404'
end
