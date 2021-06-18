;;; lang/graphql/config.el -*- lexical-binding: t; -*-
(use-package! graphql-mode
  :mode "\\.graphql\\'"
  :config
  (set-company-backend! 'graphql-mode '(company-dabbrev company-yasnippet))
  )
