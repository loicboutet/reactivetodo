class HomeController < ApplicationController

  def index
    render_component todos: TodoItem.all
  end

end
