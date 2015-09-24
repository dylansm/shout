tpl =			require '../templates/pages/group-lock'
errorTpl =		require '../templates/pages/error'
mainTpl =		require '../templates/main'





onError = (context, reply, text, code) ->
	context.notices.push
		type:	'error'
		text:	text
	response = reply mainTpl context, tpl context
	response.statusCode = code



module.exports = (req, reply) ->
	context =
		site:		@site
		group:
			name:	req.params.group
		notices:	[]
	orm = @orm

	orm.getGroup req.params.group
	.then (group) ->

		if not group
			context.error =
				short:		'not found'
				message:	"There is no group <code>#{req.params.group}</code>."
			response = reply mainTpl context, errorTpl context
			response.statusCode = 404
			return

		if group.key isnt req.params.key
			context.error =
				short:		'wrong key'
				message:	"The key is incorrect."
			response = reply mainTpl context, errorTpl context
			response.statusCode = 403
			return

		context.group = group
		context.group.name = req.params.group
		context.group.locked = true

		orm.setGroup req.params.group, context.group
		.then () ->
			reply mainTpl contect, tpl context
		.catch (err) ->
			context.error =
				short:		'internal error'
				message:	'An internal error occured.'
			response = reply mainTpl contect, errorTpl context
			response.statusCode = 500
