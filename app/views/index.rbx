# views/components/home/index.rb
module Components
  module Home
    class Index

      include React::Component

      define_state :current_mode
      define_state :current_scope

      before_mount do
        set_scope(:all)
      end

      after_mount do
        every(10) { set_scope }
      end

      def set_scope(mode = current_mode)
        if mode.is_a? Array
          if mode.include? current_mode
            mode = current_mode
          else
            mode = mode.first
          end
        end
        TodoItem.send("#{mode}=", nil) # clear scope forcing a refetch from server
        current_mode! mode
        current_scope! TodoItem.send(mode)
      end

      def clear_completed
        TodoItem.completed = nil
        ReactiveRecord.load do # returns a promise that will resolve when all items have been loaded
          TodoItem.completed.all
        end.then do |items| # the last item loaded is returned from the promise
          items.each { |item| item.destroy { set_scope :all }}
        end
      end

      def render
        div do
          div { "There are #{current_scope.count} #{current_mode+' ' unless current_mode == :all} todo#{'s' if current_scope.count > 1}" }
          current_scope.each do |todo|
            Todo todo: todo, set_scope: -> {set_scope}
          end
          button { "completed" }.on(:click) { set_scope :completed }
          button { "uncompleted" }.on(:click) { set_scope :uncompleted }
          button { "all" }.on(:click) { set_scope :all }
          button { "clear completed" }.on(:click) { clear_completed }
          button { "create" }.on(:click) { TodoItem.new(title: "test").save { set_scope([:all, :uncompleted]) } }
        end
      end

    end

    class Todo
      include React::Component
      required_param :todo, type: TodoItem
      required_param :set_scope, type: Proc
      def render
        div do
          input(type: :checkbox, (todo.complete ? :checked : :unchecked) => true).on(:click) do
            todo.complete = !todo.complete
            todo.save { set_scope }
          end
          todo.title.span
        end
      end
    end
  end
end
