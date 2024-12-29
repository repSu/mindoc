<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>{{i18n .Lang "doc.edit_doc"}} - Powered by MinDoc</title>
    <script type="text/javascript">
        window.IS_ENABLE_IFRAME = '{{conf "enable_iframe" }}' === 'true';
        window.BASE_URL = '{{urlfor "HomeController.Index" }}';
    </script>
    <script type="text/javascript">
        window.treeCatalog = null;
        window.baseUrl = "{{.BaseUrl}}";
        window.saveing = false;
        window.katex = { js: "{{cdnjs "/static/katex/katex"}}",css: "{{cdncss "/static/katex/katex"}}"};
        window.editormdLib = "{{cdnjs "/static/editor.md/lib/"}}";
        window.editor = null;
        window.imageUploadURL = "{{urlfor "DocumentController.Upload" "identify" .Model.Identify}}";
        window.fileUploadURL = "{{urlfor "DocumentController.Upload" "identify" .Model.Identify}}";
        window.documentCategory = {{.Result}};
        window.book = {{.ModelResult}};
        window.selectNode = null;
        window.deleteURL = "{{urlfor "DocumentController.Delete" ":key" .Model.Identify}}";
        window.editURL = "{{urlfor "DocumentController.Content" ":key" .Model.Identify ":id" ""}}";
        window.releaseURL = "{{urlfor "BookController.Release" ":key" .Model.Identify}}";
        window.sortURL = "{{urlfor "BookController.SaveSort" ":key" .Model.Identify}}";
        window.historyURL = "{{urlfor "DocumentController.History"}}";
        window.removeAttachURL = "{{urlfor "DocumentController.RemoveAttachment"}}";
        window.highlightStyle = "{{.HighlightStyle}}";
        window.template = { "getUrl":"{{urlfor "TemplateController.Get"}}", "listUrl" : "{{urlfor "TemplateController.List"}}", "deleteUrl" : "{{urlfor "TemplateController.Delete"}}", "saveUrl" :"{{urlfor "TemplateController.Add"}}"}
        window.lang = {{i18n $.Lang "common.js_lang"}};
    </script>
    <!-- Bootstrap -->
    <link href="{{cdncss "/static/bootstrap/css/bootstrap.min.css"}}" rel="stylesheet">
    <link href="{{cdncss "/static/font-awesome/css/font-awesome.min.css"}}" rel="stylesheet">
    <link href="{{cdncss "/static/jstree/3.3.4/themes/default/style.min.css"}}" rel="stylesheet">
    <link href="{{cdncss "/static/editor.md/css/editormd.css" "version"}}" rel="stylesheet">

    <link href="{{cdncss "/static/css/jstree.css"}}" rel="stylesheet">
    <link href="{{cdncss "/static/webuploader/webuploader.css"}}" rel="stylesheet">
    <link href="{{cdncss "/static/css/markdown.css" "version"}}" rel="stylesheet">
    <link href="{{cdncss "/static/css/markdown.preview.css" "version"}}" rel="stylesheet">
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="/static/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="/static/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style type="text/css">
        .text{
            font-size: 12px;
            color: #999999;
            font-weight: 200;
        }

        /* 基础布局 */
        .m-manual.manual-editor {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            overflow: hidden;
        }

        /* 工具栏 */
        .manual-head {
            position: relative;
            width: 100%;
            height: 45px;  /* 固定高度 */
            background: #fff;
            border-bottom: 1px solid #ddd;
            padding: 5px;
            z-index: 900;
            overflow-x: auto;
            overflow-y: hidden;
            white-space: nowrap;
            -webkit-overflow-scrolling: touch;
        }

        .manual-head::-webkit-scrollbar {
            height: 3px;
        }

        .manual-head::-webkit-scrollbar-thumb {
            background: rgba(0,0,0,.2);
            border-radius: 3px;
        }

        .editormd-group {
            display: inline-block;
            float: none;
            padding: 0 5px;
        }

        .editormd-group.pull-right {
            float: none !important;
        }

        /* 主体内容区 */
        .manual-body {
            position: absolute;
            left: 0;
            right: 0;
            bottom: 0;
            top: 45px;  /* 与工具栏高度对应 */
            background-color: #fff;
            overflow: hidden;
        }

        .manual-category {
            position: absolute;
            width: 280px;
            top: 0;
            left: 0;
            bottom: 0;
            background: #fff;
            border-right: 1px solid #ddd;
            overflow: auto;
        }

        .manual-editor-container {
            position: absolute;
            top: 0;
            left: 280px;
            right: 0;
            bottom: 0;
            overflow: auto;
        }

        /* 移动端样式 */
        @media screen and (max-width: 840px) {
            /* 工具栏响应式 */
            .manual-head {
                overflow-x: auto;
                white-space: nowrap;
                -webkit-overflow-scrolling: touch;
            }

            /* 左侧目录 */
            .manual-category {
                position: fixed;
                left: -280px;
                z-index: 1000;
                transition: left 0.3s;
                box-shadow: 2px 0 8px rgba(0,0,0,0.15);
            }

            .manual-category.show {
                left: 0;
            }

            /* 编辑器容器 */
            .manual-editor-container {
                left: 0;
                min-width: auto !important;
            }

            /* 目录切换按钮 */
            #category-toggle {
                position: fixed;
                left: 0;
                top: 50%;
                transform: translateY(-50%);
                z-index: 1001;
                padding: 8px;
                background: #fff;
                border: 1px solid #ddd;
                border-left: none;
                border-radius: 0 4px 4px 0;
                box-shadow: 2px 0 8px rgba(0,0,0,0.1);
            }

            #category-toggle.show {
                left: 280px;
            }
        }

        /* PC端额外样式 */
        @media screen and (min-width: 841px) {
            #category-toggle {
                display: none;
            }
        }
    </style>
</head>
<body>

<div class="m-manual manual-editor">
    <div class="manual-head" id="editormd-tools">
        <div class="editormd-group">
            <a href="javascript:" onclick="self.location=document.referrer;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.backward"}}"><i class="fa fa-chevron-left" aria-hidden="true"></i></a>
        </div>
        <div class="editormd-group">
            <a href="javascript:;" id="markdown-save" data-toggle="tooltip" data-title="{{i18n .Lang "doc.save"}}" class="disabled save"><i class="fa fa-save first" aria-hidden="true" name="save"></i></a>
            <a href="javascript:;" id="markdown-template" data-toggle="tooltip" data-title="{{i18n .Lang "doc.save_as_tpl"}}" class="template"><i class="fa fa-briefcase last" aria-hidden="true" name="save-template"></i></a>
        </div>
        <div class="editormd-group">
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.undo"}} (Ctrl-Z)"><i class="fa fa-undo first" name="undo" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.redo"}} (Ctrl-Y)"><i class="fa fa-repeat last" name="redo" unselectable="on"></i></a>
        </div>
        <div class="editormd-group">
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.bold"}}"><i class="fa fa-bold first" name="bold" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.italic"}}"><i class="fa fa-italic item" name="italic" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.strikethrough"}}"><i class="fa fa-strikethrough last" name="del" unselectable="on"></i></a>
        </div>
        <div class="editormd-group">
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.h1"}}"><i class="fa editormd-bold first" name="h1" unselectable="on">H1</i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.h2"}}"><i class="fa editormd-bold item" name="h2" unselectable="on">H2</i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.unorder_list"}}"><i class="fa fa-list-ul first" name="list-ul" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.order_list"}}"><i class="fa fa-list-ol item" name="list-ol" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.hline"}}"><i class="fa fa-minus last" name="hr" unselectable="on"></i></a>
        </div>
        <div class="editormd-group">
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.link"}}"><i class="fa fa-link first" name="link" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.ref_link"}}"><i class="fa fa-anchor item" name="reference-link" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.add_pic"}}"><i class="fa fa-picture-o item" name="image" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.code"}}"><i class="fa fa-code item" name="code" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.code_block"}}" unselectable="on"><i class="fa fa-file-code-o item" name="code-block" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.table"}}"><i class="fa fa-table item" name="table" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.quote"}}"><i class="fa fa-quote-right item" name="quote" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.gfm_task"}}"><i class="fa fa-tasks item" name="tasks" aria-hidden="true"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.attachment"}}"><i class="fa fa-paperclip item" aria-hidden="true" name="attachment"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.json_to_table"}}"><i class="fa fa-wrench item" aria-hidden="true" name="json"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.draw"}}"><i class="fa fa-paint-brush item" aria-hidden="true" name="drawio"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.template"}}"><i class="fa fa-tachometer last" name="template"></i></a>

            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.word_to_html"}}"><i class="fa fa-file-word-o last" name="wordToContent"></i></a>

            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.html_to_markdown"}}"><i class="fa fa-html5 last" name="htmlToMarkdown"></i></a>

        </div>

        <div class="editormd-group pull-right">
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.close_preview"}}"><i class="fa fa-eye-slash first" name="watch" unselectable="on"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.modify_history"}}"><i class="fa fa-history item" name="history" aria-hidden="true"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.sidebar"}}"><i class="fa fa-columns item" aria-hidden="true" name="sidebar"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.help"}}"><i class="fa fa-question-circle-o last" aria-hidden="true" name="help"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.changetheme"}}"><i class="fa fa-paint-brush item" aria-hidden="true" name="changetheme"></i></a>
        </div>

        <div class="editormd-group pull-right">
            <!--<a target="_blank" href="{{urlfor "DocumentController.Read" ":key" .Model.Identify ":id" ""}}" data-toggle="tooltip" data-title="{{i18n .Lang "blog.preview"}}"><i class="fa fa-external-link" name="preview-open" aria-hidden="true"></i></a>-->
            <a href="{{urlfor "DocumentController.Read" ":key" .Model.Identify ":id" ""}}" data-toggle="tooltip" data-title="{{i18n .Lang "blog.preview"}}"><i class="fa fa-external-link" name="preview-open" aria-hidden="true"></i></a>
            <a href="javascript:;" data-toggle="tooltip" data-title="{{i18n .Lang "doc.publish"}}"><i class="fa fa-cloud-upload" name="release" aria-hidden="true"></i></a>
        </div>

        <div class="editormd-group">
            <a href="javascript:;" data-toggle="tooltip" data-title=""></a>
            <a href="javascript:;" data-toggle="tooltip" data-title=""></a>
        </div>

        <div class="clearfix"></div>
    </div>
    <div class="manual-body">
        <button id="category-toggle" class="btn btn-default btn-sm">
            <i class="fa fa-angle-right"></i>
        </button>
        <div class="manual-category" id="manualCategory" style="position:absolute;">
            <div class="manual-nav">
                <div class="nav-item active"><i class="fa fa-bars" aria-hidden="true"></i> {{i18n .Lang "doc.document"}}</div>
                <div class="nav-plus pull-right" id="btnAddDocument" data-toggle="tooltip" data-title="{{i18n .Lang "doc.create_doc"}}" data-direction="right"><i class="fa fa-plus" aria-hidden="true"></i></div>
                <div class="clearfix"></div>
            </div>
            <div class="manual-tree" id="sidebar"> </div>
        </div>
        <div class="manual-editor-container" id="manualEditorContainer" style="min-width: 920px;">
            <div class="manual-editormd">
                <div id="docEditor" class="manual-editormd-active"></div>
            </div>
            <div class="manual-editor-status">
                <div id="attachInfo" class="item">0 {{i18n .Lang "doc.attachments"}}</div>
            </div>
        </div>

    </div>
</div>
<!-- 创建文档 -->
<div class="modal fade" id="addDocumentModal" tabindex="-1" role="dialog" aria-labelledby="addDocumentModalLabel">
    <div class="modal-dialog" role="document">
        <form method="post" action="{{urlfor "DocumentController.Create" ":key" .Model.Identify}}" id="addDocumentForm" class="form-horizontal">
            <input type="hidden" name="identify" value="{{.Model.Identify}}">
            <input type="hidden" name="doc_id" value="0">
            <input type="hidden" name="parent_id" value="0">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">{{i18n .Lang "doc.create_doc"}}</h4>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="col-sm-2 control-label">{{i18n .Lang "doc.doc_name"}} <span class="error-message">*</span></label>
                    <div class="col-sm-10">
                        <input type="text" name="doc_name" id="documentName" placeholder="{{i18n .Lang "doc.doc_name"}}" class="form-control"  maxlength="50">
                        <p style="color: #999;font-size: 12px;">{{i18n .Lang "doc.doc_name_tips"}}</p>

                    </div>
                </div>
                <div class="form-group">
                    <label class="col-sm-2 control-label">{{i18n .Lang "doc.doc_id"}} <span class="error-message">&nbsp;</span></label>
                    <div class="col-sm-10">
                        <input type="text" name="doc_identify" id="documentIdentify" placeholder="{{i18n .Lang "doc.doc_id"}}" class="form-control" maxlength="50">
                        <p style="color: #999;font-size: 12px;">{{i18n .Lang "doc.doc_id_tips"}}</p>
                    </div>

                </div>
                <div class="form-group">
                        <div class="col-lg-4">
                            <label>
                                <input type="radio" name="is_open" value="1"> {{i18n .Lang "doc.expand"}}<span class="text">{{i18n .Lang "doc.expand_desc"}}</span>
                            </label>
                        </div>
                        <div class="col-lg-4">
                            <label>
                                <input type="radio" name="is_open" value="0" checked> {{i18n .Lang "doc.fold"}}<span class="text">{{i18n .Lang "doc.fold_desc"}}</span>
                            </label>
                        </div>
                    <div class="col-lg-4">
                        <label>
                            <input type="radio" name="is_open" value="2"> {{i18n .Lang "doc.empty_contents"}}<span class="text">{{i18n .Lang "doc.empty_contents_desc"}}</span>
                        </label>
                    </div>
                    <div class="clearfix"></div>
                </div>
            </div>
            <div class="modal-footer">
                <span id="add-error-message" class="error-message"></span>
                <button type="button" class="btn btn-default" data-dismiss="modal">{{i18n .Lang "common.cancel"}}</button>
                <button type="submit" class="btn btn-primary" id="btnSaveDocument" data-loading-text="{{i18n .Lang "message.processing"}}">{{i18n .Lang "doc.save"}}</button>
            </div>
        </div>
        </form>
    </div>
</div>

<!-- 显示附件 --->
<div class="modal fade" id="uploadAttachModal" tabindex="-1" role="dialog" aria-labelledby="uploadAttachModalLabel">
    <div class="modal-dialog" role="document">
        <form method="post" id="uploadAttachModalForm" class="form-horizontal">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel">{{i18n .Lang "doc.upload_attachment"}}</h4>
                </div>
                <div class="modal-body">
                    <div class="attach-drop-panel">
                        <div class="upload-container" id="filePicker"><i class="fa fa-upload" aria-hidden="true"></i></div>
                    </div>
                    <div class="attach-list" id="attachList">
                        <template v-for="item in lists">
                            <div class="attach-item" :id="item.attachment_id">
                                <template v-if="item.state == 'wait'">
                                    <div class="progress">
                                        <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100">
                                            <span class="sr-only">0% Complete (success)</span>
                                        </div>
                                    </div>
                                </template>
                                <template v-else-if="item.state == 'error'">
                                    <span class="error-message">${item.message}</span>
                                    <button type="button" class="btn btn-sm close" @click="removeAttach(item.attachment_id)">
                                        <i class="fa fa-remove" aria-hidden="true"></i>
                                    </button>
                                </template>
                                <template v-else>
                                    <a :href="item.http_path" target="_blank" :title="item.file_name">${item.file_name}</a>
                                    <span class="text">(${ formatBytes(item.file_size) })</span>
                                    <span class="error-message">${item.message}</span>
                                    <button type="button" class="btn btn-sm close" @click="removeAttach(item.attachment_id)">
                                        <i class="fa fa-remove" aria-hidden="true"></i>
                                    </button>
                                    <div class="clearfix"></div>
                                </template>
                            </div>
                        </template>
                    </div>
                </div>
                <div class="modal-footer">
                    <span id="add-error-message" class="error-message"></span>
                    <button type="button" class="btn btn-default" data-dismiss="modal">{{i18n .Lang "common.cancel"}}</button>
                    <button type="button" class="btn btn-primary" id="btnUploadAttachFile" data-dismiss="modal">{{i18n .Lang "common.confirm"}}</button>
                </div>
            </div>
        </form>
    </div>
</div>
<!-- 显示文档历史 -->
<div class="modal fade" id="documentHistoryModal" tabindex="-1" role="dialog" aria-labelledby="documentHistoryModalModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">{{i18n .Lang "doc.doc_history"}}</h4>
            </div>
            <div class="modal-body text-center" id="historyList">

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{i18n .Lang "doc.close"}}</button>
            </div>
        </div>
    </div>
</div>
<!--- 选择模板--->
<div class="modal fade" id="documentTemplateModal" tabindex="-1" role="dialog" aria-labelledby="{{i18n .Lang "doc.choose_template_type"}}" aria-hidden="true">
    <div class="modal-dialog" style="width: 780px;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="modal-title">{{i18n .Lang "doc.choose_template_type"}}</h4>
            </div>
            <div class="modal-body template-list">
                <div class="container">
                    <div class="section">
                        <a data-type="normal" href="javascript:;"><i class="fa fa-file-o"></i></a>
                        <h3><a data-type="normal" href="javascript:;">{{i18n .Lang "doc.normal_tpl"}}</a></h3>
                        <ul>
                            <li>{{i18n .Lang "doc.tpl_default_type"}}</li>
                            <li>{{i18n .Lang "doc.tpl_plain_text"}}</li>
                        </ul>
                    </div>
                    <div class="section">
                        <a data-type="api" href="javascript:;"><i class="fa fa-file-code-o"></i></a>
                        <h3><a data-type="api" href="javascript:;">{{i18n .Lang "doc.api_tpl"}}</a></h3>
                        <ul>
                            <li>{{i18n .Lang "doc.for_api_doc"}}</li>
                            <li>{{i18n .Lang "doc.code_highlight"}}</li>
                        </ul>
                    </div>
                    <div class="section">
                        <a data-type="code" href="javascript:;"><i class="fa fa-book"></i></a>

                        <h3><a data-type="code" href="javascript:;">{{i18n .Lang "doc.data_dict"}}</a></h3>
                        <ul>
                            <li>{{i18n .Lang "doc.for_data_dict"}}</li>
                            <li>{{i18n .Lang "doc.form_support"}}</li>
                        </ul>
                    </div>
                    <div class="section">
                        <a data-type="customs" href="javascript:;"><i class="fa fa-briefcase"></i></a>

                        <h3><a data-type="customs" href="javascript:;">{{i18n .Lang "doc.custom_tpl"}}</a></h3>
                        <ul>
                            <li>{{i18n .Lang "doc.any_type_doc"}}</li>
                            <li>{{i18n .Lang "doc.as_global_tpl"}}</li>
                        </ul>
                    </div>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{i18n .Lang "common.cancel"}}</button>
            </div>
        </div>
    </div>
</div>
<!--- 显示自定义模板--->
<div class="modal fade" id="displayCustomsTemplateModal" tabindex="-1" role="dialog" aria-labelledby="displayCustomsTemplateModalLabel">
    <div class="modal-dialog" role="document" style="width: 750px;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">{{i18n .Lang "doc.custom_tpl"}}</h4>
            </div>
            <div class="modal-body text-center" id="displayCustomsTemplateList">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                        <tr>
                            <td>#</td>
                            <td class="col-sm-3">{{i18n $.Lang "doc.tpl_name"}}</td>
                            <td class="col-sm-2">{{i18n $.Lang "doc.tpl_type"}}</td>
                            <td class="col-sm-2">{{i18n $.Lang "doc.creator"}}</td>
                            <td class="col-sm-3">{{i18n $.Lang "doc.create_time"}}</td>
                            <td class="col-sm-2">{{i18n $.Lang "doc.operation"}}</td>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td colspan="7" class="text-center">{{i18n .Lang "message.no_data"}}</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{i18n .Lang "doc.close"}}</button>
            </div>
        </div>
    </div>
</div>
<!--- 创建模板--->
<div class="modal fade" id="saveTemplateModal" tabindex="-1" role="dialog" aria-labelledby="saveTemplateModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form method="post" action="{{urlfor "TemplateController.Add"}}" id="saveTemplateForm" class="form-horizontal">
                <input type="hidden" name="identify" value="{{.Model.Identify}}">
                <input type="hidden" name="content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title">{{i18n .Lang "doc.save_as_tpl"}}</h4>
                </div>
                <div class="modal-body text-center">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">{{i18n .Lang "doc.tpl_name"}} <span class="error-message">*</span></label>
                        <div class="col-sm-10">
                            <input type="text" name="template_name" id="templateName" placeholder="{{i18n .Lang "doc.tpl_name"}}" class="form-control"  maxlength="50">
                        </div>
                    </div>
                    {{if eq .Member.Role 0 1}}
                    <div class="form-group">
                        <div class="col-lg-6">
                            <label>
                                <input type="radio" name="is_global" value="1"> {{i18n .Lang "doc.global_tpl"}}<span class="text">{{i18n .Lang "doc.global_tpl_desc"}}</span>
                            </label>
                        </div>
                        <div class="col-lg-6">
                            <label>
                                <input type="radio" name="is_global" value="0" checked> {{i18n .Lang "doc.project_tpl"}}<span class="text">{{i18n .Lang "doc.project_tpl_desc"}}</span>
                            </label>
                        </div>
                        <div class="clearfix"></div>
                    </div>
                    {{end}}
                </div>
                <div class="modal-footer">
                    <span class="error-message show-error-message"></span>
                    <button type="button" class="btn btn-default" data-dismiss="modal">{{i18n .Lang "common.cancel"}}</button>
                    <button type="submit" class="btn btn-primary" id="btnSaveTemplate" data-loading-text="{{i18n .Lang "message.processing"}}">{{i18n .Lang "doc.save"}}</button>
                </div>
            </form>
        </div>
    </div>
</div>
<!--- json转换为表格 -->
<div class="modal fade" id="convertJsonToTableModal" tabindex="-1" role="dialog" aria-labelledby="convertJsonToTableModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form method="post" id="convertJsonToTableForm" class="form-horizontal">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title">{{i18n .Lang "doc.json_to_table"}}</h4>
                </div>
                <div class="modal-body text-center">
                        <textarea type="text" name="jsonContent" id="jsonContent" placeholder="Json" class="form-control" style="height: 300px;resize: none"></textarea>

                </div>
                <div class="modal-footer">
                    <span id="json-error-message"></span>
                    <button type="button" class="btn btn-default" data-dismiss="modal">{{i18n .Lang "common.cancel"}}</button>
                    <button type="button" class="btn btn-primary" id="btnInsertTable" data-loading-text="{{i18n .Lang "message.processing"}}">{{i18n .Lang "doc.insert"}}</button>
                </div>
            </form>
        </div>
    </div>
</div>
<template id="template-normal">
{{if eq .Lang "en-us"}}
{{template "document/template_normal-en.tpl"}}
{{else}}
{{template "document/template_normal.tpl"}}
{{end}}
</template>
<template id="template-api">
{{if eq .Lang "en-us"}}
{{template "document/template_api-en.tpl"}}
{{else}}
{{template "document/template_api.tpl"}}
{{end}}
</template>
<template id="template-code">
{{if eq .Lang "en-us"}}
{{template "document/template_code-en.tpl"}}
{{else}}
{{template "document/template_code.tpl"}}
{{end}}
</template>
<script src="{{cdnjs "/static/js/array.js" "version"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/jquery/1.12.4/jquery.min.js"}}"></script>
<script src="{{cdnjs "/static/vuejs/vue.min.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/bootstrap/js/bootstrap.min.js"}}"></script>
<script src="{{cdnjs "/static/webuploader/webuploader.min.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/jstree/3.3.4/jstree.min.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/editor.md/editormd.js" "version"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/layer/layer.js"}}" type="text/javascript" ></script>
<script src="{{cdnjs "/static/js/jquery.form.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/js/array.js" "version"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/js/editor.js" "version"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/table-editor/dist/index.js" "version"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/js/markdown.js" "version"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/js/custom-elements-builtin-0.6.5.min.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/js/x-frame-bypass-1.0.2.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/mammoth/mammoth.browser.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/turndown/turndown.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/js/word-to-html.js"}}" type="text/javascript"></script>
<script src="{{cdnjs "/static/js/html-to-markdown.js"}}" type="text/javascript"></script>
<script type="text/javascript">
    $(function () {
        editLangPath = {{cdnjs "/static/editor.md/languages/"}} + lang
        if(lang != 'zh-CN') {
            editormd.loadScript(editLangPath, function(){
                window.editor.lang = editormd.defaults.lang;
                window.editor.recreate()
            });
        }
        
        $("#attachInfo").on("click",function () {
            $("#uploadAttachModal").modal("show");
        });
        window.uploader = null;

        $("#uploadAttachModal").on("shown.bs.modal",function () {
            if(window.uploader === null){
                try {
                    window.uploader = WebUploader.create({
                        auto: true,
                        dnd : true,
                        swf: '{{.BaseUrl}}/static/webuploader/Uploader.swf',
                        server: '{{urlfor "DocumentController.Upload"}}',
                        formData : { "identify" : {{.Model.Identify}},"doc_id" :  window.selectNode.id },
                        pick: "#filePicker",
                        fileVal : "editormd-file-file",
                        compress : false,
                        fileSingleSizeLimit: {{.UploadFileSize}}
                    }).on("beforeFileQueued",function (file) {
                        // uploader.reset();
                        this.options.formData.doc_id = window.selectNode.id;
                    }).on( 'fileQueued', function( file ) {
                        var item = {
                            state : "wait",
                            attachment_id : file.id,
                            file_size : file.size,
                            file_name : file.name,
                            message : "{{i18n .Lang "doc.uploading"}}"
                        };
                        window.vueApp.lists.push(item);

                    }).on("uploadError",function (file,reason) {
                        for(var i in window.vueApp.lists){
                            var item = window.vueApp.lists[i];
                            if(item.attachment_id == file.id){
                                item.state = "error";
                                item.message = "{{i18n .Lang "message.upload_failed"}}:" + reason;
                                break;
                            }
                        }

                    }).on("uploadSuccess",function (file, res) {
                        for(var index in window.vueApp.lists){
                            var item = window.vueApp.lists[index];
                            if(item.attachment_id === file.id){
                                if(res.errcode === 0) {
                                    window.vueApp.lists.splice(index, 1, res.attach ? res.attach : res.data);
                                }else{
                                    item.message = res.message;
                                    item.state = "error";
                                }
                            }
                        }
                    }).on("uploadProgress",function (file, percentage) {
                        var $li = $( '#'+file.id ),
                            $percent = $li.find('.progress .progress-bar');

                        $percent.css( 'width', percentage * 100 + '%' );
                    }).on("error", function (type) {
                        if(type === "F_EXCEED_SIZE"){
                            layer.msg("{{i18n .Lang "message.upload_file_size_limit"}}");
                        }
                        console.log(type);
                    });
                }catch(e){
                    console.log(e);
                }
            }
        });

        // 移动端目录切换
        $("#category-toggle").on("click", function() {
            var $category = $("#manualCategory");
            var $toggle = $(this);
            var $icon = $toggle.find("i");
            
            $category.toggleClass("show");
            $toggle.toggleClass("show");
            
            if ($category.hasClass("show")) {
                $icon.removeClass("fa-angle-right").addClass("fa-angle-left");
            } else {
                $icon.removeClass("fa-angle-left").addClass("fa-angle-right");
            }
        });

        // 点击文档区域时收起移动端目录
        $("#manualEditorContainer").on("click", function() {
            if (window.innerWidth <= 840) {
                $("#manualCategory").removeClass("show");
                var $toggle = $("#category-toggle");
                $toggle.removeClass("show")
                    .find("i")
                    .removeClass("fa-angle-left")
                    .addClass("fa-angle-right");
            }
        });

        // 监听窗口大小变化
        $(window).on("resize", function() {
            var isMobile = window.innerWidth <= 840;
            if (!isMobile) {
                $("#manualCategory").removeClass("show");
                $("#category-toggle").removeClass("show")
                    .find("i").removeClass("fa-angle-left").addClass("fa-angle-right");
            }
        });

        // 调整内容区域位置
        function adjustContentPosition() {
            var toolbarHeight = $('.manual-head').outerHeight();
            $('.manual-body').css('top', toolbarHeight + 'px');
        }
        
        // 页面加载和窗口大小改变时调整
        adjustContentPosition();
        $(window).on('resize', adjustContentPosition);
        
        // 监听工具栏高度变化
        var toolbarObserver = new ResizeObserver(function() {
            adjustContentPosition();
        });
        toolbarObserver.observe($('.manual-head')[0]);
    });
</script>
</body>
</html>