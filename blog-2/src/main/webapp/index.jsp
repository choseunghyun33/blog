<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>INDEX</title>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">
<!-- jQuery library -->
<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.slim.min.js"></script>
<!-- Popper JS -->
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js"></script>
<style>
a {
    color: pink;
}
.page-link {
	color: pink;
}
</style>
</head>
<body>
	<%
		// Invalid ID or PW errorMsg
		if(request.getParameter("errorMsg") != null){
	%>	
			<div><%=request.getParameter("errorMsg")%></div>
	<%	
		}
	%>
	<div class="container">
		<h1 class="container p-3 my-3 border">index</h1>
		<div>
			<a href="./boardList.jsp" class="btn btn-outline-light text-dark">게시판</a>
			<a href="./guestbook.jsp" class="btn btn-outline-light text-dark">방명록</a>
			<a href="./diary.jsp" class="btn btn-outline-light text-dark">다이어리</a>
		</div>
		<hr>
		<%
			if(session.getAttribute("loginId") == null){ // 로그인 전
		%>
				<h2>로그인</h2>
				<form action="./loginAction.jsp" method="post">
					<table class="table table-hover table-striped">
						<tr>
							<td>id</td>
							<td><input type="text" name="id" value="admin"></td>
						</tr>
						<tr>
							<td>pw</td>
							<td><input type="password" name="pw" value="1234"></td>
						</tr>
					</table>
					<button type="submit" class="btn btn-outline-dark">로그인</button>
					<a href="./insertMemberForm.jsp" class="btn btn-outline-light text-dark">회원가입</a>
				</form>
		<%
			} else { // 로그인 됨
		%>
				<h2><%=session.getAttribute("loginId")%>(<%=session.getAttribute("loginLevel")%>)님 반갑습니다</h2>
				<a href="./logout.jsp" class="btn btn-outline-light text-dark">로그아웃</a>
		<%		
			}
		%>
	</div>
</body>
</html>