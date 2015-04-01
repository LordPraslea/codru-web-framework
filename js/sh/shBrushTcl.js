/**
 * SyntaxHighlighter brush for Tcl
 *
 * Customized by ekd123.
 *
 * more info:
 * http://blog.henix.info/blog/tcl-syntaxhighlighter-brush.html
 *
 * @version 0.3
 *
 * @copyright
 * Copyright (C) 2011-2012 henix.
 *
 * @license
 * Dual licensed under the MIT and GPL licenses.
 */

/**
 * ChangeLog
 *
 * 2012-2-28 henix
 *     move some commands to keywords
 *     render [] in color2
 *     add array, dict and string subcommands
 *
 * 2011-12-23 henix
 *     website moved to blog.henix.info
 *
 * 2011-4-16 henix
 *     Version 1.0
 */


;(function()
{
	// CommonJS
	typeof(require) != 'undefined' ? SyntaxHighlighter = require('shCore').SyntaxHighlighter : null;

	function Brush() 	
	{
		
	// According to: http://www.tcl.tk/man/tcl8.5/TclCmd/contents.htm
	var tclcommands = 'after append apply array bgerror binary cd chan clock close concat dde dict encoding eof error eval exec exit expr fblocked fconfigure fcopy file fileevent filename flush format gets glob history http incr info interp join lappend lassign lindex linsert list llength load lrange lrepeat lreplace lreverse lsearch lset lsort mathfunc mathop memory msgcat open parray pid platform puts pwd read refchan regexp registry regsub rename scan seek socket source split string subst switch tcltest tclvars tell time tm trace unknown unload update uplevel variable vwait yieldm oo::objdefine ';
	var tkcommands = 'bell bind bindtags bitmap busy button canvas checkbutton clipboard console destroy entry event focus font fontchooser frame geometry grab grid image label labelframe listbox lower menu menubutton message option pack panedwindow photo place radiobutton raise scale scrollbar selection send spinbox text tk tk::mac tk_bisque tk_chooseColor tk_chooseDirectory tk_dialog tk_focusFollowsMouse tk_focusNext tk_focusPrev tk_getOpenFile tk_getSaveFile tk_library tk_menuSetFocus tk_messageBox tk_optionMenu tk_patchLevel tk_popup tk_setPalette tk_textCopy tk_textCut tk_textPaste tk_version tkerror tkwait toplevel ttk::button ttk::checkbutton ttk::combobox ttk::entry ttk::frame ttk::label ttk::labelframe ttk::menubutton ttk::notebook ttk::panedwindow ttk::progressbar ttk::radiobutton ttk::scale ttk::scrollbar ttk::separator ttk::sizegrip ttk::spinbox ttk::style ttk::treeview ttk_image ttk_vsapi winfo wm ';
	var commands = tclcommands + tkcommands;

	/**
	 * According to http://www.tcl.tk/man/tcl8.5/tutorial/Tcl11.html , there are no reserved words in Tcl,
	 * but in practice, we usually treat these commands as keywords.
	 */
	var keywords = 'proc if else elseif then return while for set unset break continue foreach package namespace catch upvar global try catch tailcall coroutine yield yieldto oo::class oo::define superclass constructor destructor method mixin  ';

	this.regexList = [
		{ regex: new RegExp('^\\s*#.*$', 'gm'), css: 'comments' }, // JavaScript doesn't support lookbehind zero-width assertions, so...
		{ regex: new RegExp(';\\s*#.*$', 'gm'), css: 'comments' },
		{ regex: SyntaxHighlighter.regexLib.doubleQuotedString, css: 'string' },
		{ regex: new RegExp('\\$[A-Za-z]\\w*', 'g'), css: 'variable'},
		{ regex: new RegExp('\\b\\d+\\b', 'g'), css: 'constants' },
		{ regex: new RegExp('[\\[\\]]', 'g'), css: 'color2' },
		{ regex: new RegExp(this.getKeywords(keywords), 'g'), css: 'keyword' },
		{ regex: new RegExp(this.getKeywords(commands), 'g'), css: 'functions bold' },
		{ regex: /array (anymore|donesearch|exists|get|names|nextelement|set|size|startsearch|statistics|unset)/g, css: 'functions bold' },
		{ regex: /dict (append|create|exists|filter|for|get|incr|info|keys|lappend|merge|remove|replace|set|size|unset|update|values|with)/g, css: 'functions bold' },
		{ regex: /string (bytelength|compare|equal|first|index|is|last|length|map|match|range|repeat|replace|reverse|tolower|totitle|toupper|trim|trimleft|trimright|wordend|wordstart)/g, css: 'functions bold' }
		];
};
	Brush.prototype	= new SyntaxHighlighter.Highlighter();
	Brush.aliases	= ['tcl'];

	SyntaxHighlighter.brushes.Tcl = Brush;

	// CommonJS
	typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
})();

