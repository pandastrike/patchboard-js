assert = require "assert"
check_type = require("fairmont").type
Testify = require "testify"

assert.type = (value, string) ->
  assert.equal check_type(value), string

assert.keys = (object, keys) ->
  assert.type object, "object"
  assert.deepEqual Object.keys(object).sort(), keys.sort()


{api, SchemaManager, Action} = require "../helpers"
{type} = api

schema_manager = new SchemaManager(api.schemas...)

client = {api: {schema_manager}}

# helper functions


Testify.test "Action", (context) ->


  context.test "create_request()", (context) ->

    context.test "simple", ->
      action = new Action(client, "get", api.resources.user.actions.get)
      request = action.create_request({}, "http://somewhere.com/")
      assert.keys request, ["url", "method", "headers"]

    context.test "with content", ->
      action = new Action(client, "update", api.resources.user.actions.update)
      request = action.create_request {}, "http://somewhere.com/", {foo: "bar"}

      assert.keys request, ["body", "url", "method", "headers"]
      assert.equal request.body, JSON.stringify(foo: "bar")

    context.test "with body", ->
      action = new Action(client, "update", api.resources.user.actions.update)
      request = action.create_request {}, "http://somewhere.com/", "string body"

      assert.keys request, ["body", "url", "method", "headers"]
      assert.equal request.body, "string body"




  context.test "base_headers()", ->

    action = new Action(client, "update", api.resources.user.actions.update)
    headers = action.base_headers()
    assert.deepEqual headers,
      "User-Agent": "patchboard-js"
      "Accept": type("user")
      "Content-Type": type("user")


  context.test "process_args()", (context) ->

    context.test "action without content", ->
      action = new Action(client, "get", api.resources.user.actions.get)

      options = action.process_args []
      assert.keys options, []

      assert.throws (-> action.process_args [ {foo: "bar"} ]),
        /Invalid arguments for action/

    context.test "action with content", ->
      action = new Action(client, "update", api.resources.user.actions.update)

      options = action.process_args [ {foo: "bar"} ]
      assert.keys options, ["content"]

      options = action.process_args [ "string body" ]
      assert.keys options, ["body"]

      assert.throws (-> action.process_args [ ]),
        /Invalid arguments for action/





