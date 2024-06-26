-- mod-version:3
local core = require "core"
local command = require "core.command"
local config = require "core.config"
local treeview, treemenu, mainmenu

command.add("core.docview!", {
  ["copy-file-location:of-doc"] = function(view)
    local doc = view.doc
    if not doc.abs_filename then
      core.error "Cannot copy location of unsaved doc"
      return
    end
    core.log("Copying \"%s\" to clipboard", doc.abs_filename)
    system.set_clipboard(doc.abs_filename)
  end
})

core.add_thread(function()
  -- make sure other deferred loads have run. i.e. TreeView deferring ContextMenu
  coroutine.yield(.1)

  local _
  if false ~= config.plugins.treeview then
    _, treeview = pcall(require, "plugins.treeview")
  end
  if false ~= config.plugins.contextmenu then
    treemenu = treeview and treeview.contextmenu
    _, mainmenu = pcall(require, "plugins.contextmenu")
  end

  if treeview then
    command.add(function()
        return treeview.hovered_item ~= nil, treeview.hovered_item
      end, {
        ["copy-file-location:of-tree-view-item"] = function(item)
          if not (item and item.abs_filename) then
            core.error "Cannot copy location of item"
            return
          end
          core.log("Copying \"%s\" to clipboard", item.abs_filename)
          system.set_clipboard(item.abs_filename)
        end
    })
  end

  if treemenu then
    treemenu:register(nil, {
      {
        text = "Copy File Location",
        command = "copy-file-location:of-tree-view-item"
      }
    })
  end

  if mainmenu then
    mainmenu:register("core.docview!", {
      {
        text = "Copy File Location",
        command = "copy-file-location:of-doc"
      }
    })
  end
end)

