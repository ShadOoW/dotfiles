-- Custom command for :Q to behave like :q
vim.api.nvim_create_user_command(
	"Q",
	"q",
	{}
)
vim.api.nvim_create_user_command(
	"Qa",
	"qa",
	{}
)
vim.api.nvim_create_user_command(
	"Qa",
	"qa!",
	{
		bang = true,
	}
)
