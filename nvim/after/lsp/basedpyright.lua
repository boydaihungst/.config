---@type vim.lsp.Config
return {
  before_init = function(_, c)
    if not c.settings then c.settings = {} end
    if not c.settings.python then c.settings.python = {} end
    c.settings.python.pythonPath = vim.fn.exepath "python"
  end,
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        diagnosticSeverityOverrides = {
          reportUnusedImport = "information",
          reportUnusedFunction = "information",
          reportUnusedVariable = "information",
          reportGeneralTypeIssues = "none",
          reportOptionalMemberAccess = "none",
          reportOptionalSubscript = "none",
          reportPrivateImportUsage = "none",
        },
      },
    },
  },
}
