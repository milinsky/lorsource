<%@ page contentType="text/html; charset=utf-8" %>
<%@ page
        import="java.sql.Connection,ru.org.linux.site.*,ru.org.linux.util.HTMLFormatter" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="lor" %>
<%--
  ~ Copyright 1998-2009 Linux.org.ru
  ~    Licensed under the Apache License, Version 2.0 (the "License");
  ~    you may not use this file except in compliance with the License.
  ~    You may obtain a copy of the License at
  ~
  ~        http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~    Unless required by applicable law or agreed to in writing, software
  ~    distributed under the License is distributed on an "AS IS" BASIS,
  ~    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~    See the License for the specific language governing permissions and
  ~    limitations under the License.
  --%>

<% Template tmpl = Template.getTemplate(request);%>
<%
  int topicId = (Integer) request.getAttribute("topic");
  int postscore = (Integer) request.getAttribute("postscore");

%>
<jsp:include page="/WEB-INF/jsp/head.jsp"/>

<%
  Exception error = (Exception) request.getAttribute("error");
  String mode = (String) request.getAttribute("mode");
  boolean autourl = (Boolean) request.getAttribute("autourl");
  Comment comment = (Comment) request.getAttribute("comment");

%>

<title>Добавить сообщение</title>
<jsp:include page="/WEB-INF/jsp/header.jsp"/>

<h1>Добавить комментарий</h1>

<%--<% if (tmpl.getProf().getBoolean("showinfo") && !Template.isSessionAuthorized(session)) { %>--%>
<%--<font size=2>Чтобы просто поместить сообщение, используйте login `anonymous',--%>
<%--без пароля. Если вы собираетесь активно участвовать в форуме,--%>
<%--помещать новости на главную страницу,--%>
<%--<a href="register.jsp">зарегистрируйтесь</a></font>.--%>
<%--<p>--%>

<%--<% } %>--%>
<font size=2><strong>Внимание!</strong> Перед написанием комментария ознакомьтесь с
  <a href="rules.jsp">правилами</a> сайта.</font>

<p>

    <%
  out.print(Message.getPostScoreInfo(postscore));
%>

<form method=POST action="add_comment.jsp">
  <input type="hidden" name="session"
         value="<%= HTMLFormatter.htmlSpecialChars(session.getId()) %>">
  <% if (!Template.isSessionAuthorized(session)) { %>
  Имя:
  <% if (request.getParameter("nick") != null) { %>
  <input type='text' name='nick' value="<%= request.getParameter("nick") %>" size=40><br><%
} else { %>
  <input type='text' name='nick' value="<%= "anonymous" %>" size=40><br>
  <% } %>
  Пароль:
  <input type=password name=password size=40><br>
  <% } %>
  <input type=hidden name=topic value="<%= topicId %>">

  <% if (request.getParameter("return") != null) { %>
  <input type=hidden name=return
         value="<%= HTMLFormatter.htmlSpecialChars(request.getParameter("return")) %>">
  <% } %>
  <%
    String title = "";

    Connection db = null;

    try {
      db = LorDataSource.getConnection();

      if (request.getParameter("replyto") != null) {
        int replyto = Integer.parseInt(request.getParameter("replyto"));
  %>
  <input type=hidden name=replyto value="<%= replyto %>">
  <%
        Comment onComment = (Comment) request.getAttribute("onComment");

        title = onComment.getTitle();
        if (!title.startsWith("Re:")) {
          title = "Re: " + title;
        }

        out.print("<div class=messages>");
        CommentView view = new CommentView();
        out.print(view.printMessage(onComment, tmpl, db, null, false, tmpl.isModeratorSession(), Template.getNick(session), false));
        out.print("</div>");
      }

      if (request.getParameter("title") != null) {
        title = HTMLFormatter.htmlSpecialChars(request.getParameter("title"));
      }

      if (comment != null) {
        out.print("<p><b>Ваше сообщение</b></p>");
        out.print("<div class=messages>");
        CommentView view = new CommentView();
        out.print(view.printMessage(comment, tmpl, db, null, false, tmpl.isModeratorSession(), Template.getNick(session), false));
        out.print("</div>");
      }
    } finally {
      if (db != null) {
        db.close();
      }
    }
  %>
  <% if (error != null) { %>
  <div class="error">
    ${error.message}
  </div>
  <% } %>
  
  Заглавие:
  <input type=text name=title size=40 value="<%= title %>"><br>

  Сообщение:<br>
  <font size=2>(В режиме <i>Tex paragraphs</i> игнорируются переносы строк.<br> Пустая строка (два
    раза Enter) начинает новый абзац.<br> Знак '&gt;' в начале абзаца выделяет абзац курсивом
    цитирования)</font><br>
  <textarea name="msg" cols="70"
            rows="20"><%= request.getParameter("msg") == null ? "" : HTMLFormatter.htmlSpecialChars(request.getParameter("msg"))
  %></textarea><br>

  <select name=mode>
    <option value=ntobrq <%= (mode!=null && "ntobrq".equals(mode))?"selected":""%> >User line breaks
      w/quoting
    <option value=quot <%= (mode!=null && "quot".equals(mode))?"selected":""%> >TeX paragraphs
      w/quoting
    <option value=tex <%= (mode!=null && "tex".equals(mode))?"selected":""%> >TeX paragraphs w/o
      quoting
    <option value=ntobr <%= (mode!=null && "ntobr".equals(mode))?"selected":""%> >User line break
      w/o quoting
    <option value=html <%= (mode!=null && "html".equals(mode))?"selected":""%> >Ignore line breaks
    <option value=pre <%= (mode!=null && "pre".equals(mode))?"selected":""%> >Preformatted text
  </select>

  <select name=autourl>
    <option value=1 <%= autourl?"selected":""%> >Auto URL
    <option value=0 <%= !autourl?"selected":""%> >No Auto URL
  </select>

  <input type=hidden value=0 name=texttype>

  <br>

  <%
    out.print(Message.getPostScoreInfo(postscore));
  %>

  <br>
  <lor:captcha/>
  <input type=submit value="Поместить">
  <input type=submit name=preview value="Предпросмотр">

</form>
<jsp:include page="/WEB-INF/jsp/footer.jsp"/>
