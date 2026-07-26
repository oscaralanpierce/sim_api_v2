# 0002. Use Controller Services

## Date

26-07-2026

## Approved By

@oscaralanpierce

## Decision

We will use the controller services pattern for V2 API controllers.

## Glossary

* **Controller Services Pattern:** A design pattern for Rails controllers whereas each handler is implemented in a distinct controller service class that is then called from the relevant method in the controller itself
* **Handler:** A controller method that is called when a client makes a request to a particular route
* **Route:** A combination of one HTTP method ("GET", "POST", "PUT", "PATCH", "DELETE") with one endpoint ("/widgets", "/widgets/:id", etc.)

## Context

Bloat is a common problem with Rails controllers as request-handling logic can quickly become rather Byzantine. One solution to this problem that has worked well in the V1 API is the controller services pattern. By creating a dedicated request for each handler, we can keep the controller code itself clean while encapsulating logic pertaining to specific resource endpoints in controller service classes, one per route combination. Using this approach results in very clean handler logic:

```ruby
require 'controller/response'

class WidgetsController < ApplicationController
  def update
    result = UpdateService.new(current_user, params[:widget_id], widget_params).perform

    ::Controller::Response.new(self, result).execute
  end

  private

  def widget_params
    params.require(:widget).permit(:name, :description)
  end
end
```

## Alternatives Considered

We considered implementing controllers without controller services and simply defining the code for each handler within the controller itself.

## Considerations

A key consideration in designing Rails controllers is how much logic each handler will have to encapsulate. Since we are not using Rails views, rendering will not occur "automagically" - every response has to be defined within the handler. This means a high risk of bloat, particularly if any conditional logic is introduced (e.g., branches for success and error cases). For this reason, it makes sense to think about encapsulation early.

## Summary

We will use the controller services pattern instead of coding response logic directly in controller handler methods.
