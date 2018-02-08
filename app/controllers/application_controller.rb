# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :verify_okapi_headers
  before_action :set_response_headers
  around_action :catch_exceptions
  around_action :catch_flexirest_exceptions

  def okapi
    @okapi ||= Okapi::Client.new(okapi_url, okapi_tenant, okapi_token)
  end

  def config
    @config ||= ::Configuration.new(okapi, rmapi_base_url).tap(&:load!)
  end

  def rmapi_base_url
    Rails.application.config.rmapi_base_url
  end

  def okapi_url
    request.headers['HTTP_X_OKAPI_URL']
  end

  def okapi_tenant
    request.headers['HTTP_X_OKAPI_TENANT']
  end

  def okapi_token
    request.headers['HTTP_X_OKAPI_TOKEN']
  end

  private

  def catch_exceptions
    yield
  rescue ActionController::BadRequest => e
    render jsonapi_errors: { "title": e.message },
           status: :bad_request
  end

  def catch_flexirest_exceptions
    yield
  rescue Flexirest::HTTPClientException,
         Flexirest::HTTPServerException,
         Flexirest::HTTPNotFoundClientException => e

    errors_hash = e.result.Errors.to_a.map do |err|
      { "title": err.to_hash['Message'] }
    end

    render jsonapi_errors: errors_hash,
           status: e.status
  end

  def verify_okapi_headers
    if !okapi_url
      render plain: 'Missing header X-OKAPI-URL', status: :bad_request
    elsif !okapi_tenant
      render plain: 'Missing header X-OKAPI-TENANT', status: :bad_request
    elsif !okapi_token
      render plain: 'Missing header X-OKAPI-TOKEN', status: :bad_request
    end
  end

  def set_response_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end
end
