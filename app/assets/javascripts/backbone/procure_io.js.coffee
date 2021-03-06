#= require_self
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

ProcureIo.Backbone =
  views: {}
  DEFAULT_LABEL_COLOR: "898989"

ProcureIo.Backbone.Overrides =
  modelUrl: ->
    base = _.result(@, 'urlRoot') || _.result(@collection, 'baseUrl') || urlError()
    return base if this.isNew()
    base + (if base.charAt(base.length - 1) == '/' then '' else '/') + encodeURIComponent(@id) + ".json"

Backbone.View.prototype.extendEvents = (newEvents) ->
  _.extend @events, newEvents