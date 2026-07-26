# Controller Services

Controller services are a design pattern we use to keep controller logic simple and encapsulated as described in [ADR 2](/docs/adrs/0002-use-controller-services.md).

## Table of Contents

- [Class Structure](#class-structure)
  - [The `Service::Result` Class](#the-serviceresult-class)
  - [The `Controller::Response` Class](#the-controllerresponse-class)
- [Adding Handlers to an Existing Controller](#adding-handlers-to-an-existing-controller)
- [Building New Controllers](#building-new-controllers)

## Class Structure

Controller services live in the `/app/controller_services/<controller_name>` directory, with one service for each route handled by the controller in question. So, for example, the `PlaythroughsController` might have the following structure:

`/app/`
  `controller/`
    `playthroughs_controller.rb`
  `controller_services/`
    `playthroughs_controller/`
      `create_service.rb`
      `destroy_service.rb`
      `index_service.rb`
      `show_service.rb`
      `update_service.rb`

Controller services are initialized with any params required for the request handling logic, which is then implemented in their `#perform` instance method. This method returns a subclass of `Service::Result` that includes the resource or errors to be returned in the response body.

The handler methods within the controller (e.g., `#create`, `#update`, `#show`, `#index`, `#destroy`) instantiate the relevant service and create a `Controller::Response` object with the result returned by its `#perform` method, calling `#execute` on the response object to generate a response to the request:

```ruby
require 'controller/response'

class WidgetsController < ApplicationController
  def create
    result = CreateService.new(current_user, widget_params)

    ::Controller::Response.new(self, result).execute
  end

  private

  def widget_params
    params.require(:widget).permit(:name, :description)
  end
end
```

### The `Service::Result` Class

Controller services return subclasses of `Service::Result` from their `#perform` method. Each subclass, such as `Service::OkResult` or `Service::NotFoundResult`, defines a status and either a resource or errors to be returned in the body. For a `Service::NoContentResult`, the resource and errors are both `nil`.

Each `Service::Result` subclass defines a `#status` method. This method returns the symbol that Rails uses to indicate a particular server response. For example, `:ok` becomes status 200, `:not_found` becomes status 404, etc. Successful (200-range) results have a `:resource` passed into their constructor; error results have an `:error` string or `:errors` array passed in. If a string is passed in as `:error`, it is normalised to an `:errors` array containing that string on the final result object.

### The `Controller::Response` Class

The `Controller::Response` class is instantiated with a controller instance and a `Service::Result` subclass instance. Its `#execute` method renders the status and response body indicated by the result object from the controller passed in, calling either `#head` (for the `Service::NoContentResult`) or `#render` (for all other result classes) on the controller.

## Adding Handlers to an Existing Controller

If you want to add a new route, you will need to add a handler to the relevant controller. In order to do this, you should create a controller service in the `/app/controller_services/<some_controller>/` directory with a class name corresponding to the handler. The class is then namespaced under the controller class, in keeping with Zeitwerk requirements. Any data required to handle the request, such as a logged-in user or request params, should be passed into your service's initializer and stored in instance variables. The instance method `#perform` returns whatever `Service::Result` subclasses it may need to handle the request (often a success class like `Service::OkResult` and one or more error subclasses like `Service::NotFoundResult`).

```ruby
import 'service/ok_result'
import 'service/not_found_result'
import 'service/internal_server_error_result'
import 'service/unprocessable_entity_result'

class WidgetsController < ApplicationController
  class UpdateService
    def initialize(user, params)
      @user = user
      @params = params
    end

    def perform
      widget = Widget.find(params[:id])

      return Service::NotFoundResult.new(error: "Could not find widget #{params[:id]}") if !widget

      widget.update!(params)
      Service::OkResult.new(resource: widget)
    rescue ActiveRecord::RecordInvalid => e
      Service::UnprocessableEntityResult.new(error: e.message)
    rescue StandardError => e
      Service::InternalServerErrorResult.new(error: 'Oh no')
    end

    private

    attr_reader :user, :params
  end
end
```

## Building New Controllers

When creating a new controller, such as when you've introduced a new RESTful resource, you will need to create the controller class in `/app/controllers/` and any controller services it may use in `/app/controller_services/<your_controller>/`. There should be one service class per route handler in the controller. You can define each controller service in the manner described above.
