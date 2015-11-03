# views/components/home/index.rb
module Components
  module Home
    class Index

      include React::Component

      def render
        div do
          "bhhhfhdklfd".span
          TodoItem.all.each do |todo|
            div do
              todo.complete.span; todo.title.span
              button { "complete" }.on(:click) { |evt| todo.complete = true; todo.save }
            end
          end
        end
      end

    end
  end
end
