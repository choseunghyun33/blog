<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>UPDATE-GUESTBOOK</title>
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
	// 인코딩
	request.setCharacterEncoding("UTF-8");


	// 로그인이 안되어 있는 경우 재요청
	if(session.getAttribute("loginId") == null) {
		response.sendRedirect("./index.jsp");
		return;
	}
	
	if(request.getParameter("guestbookNo") == null) {
		response.sendRedirect("./guestbook.jsp");
		return;
	}
	

	// ----------------------------------------------------------- 컨트롤러
	// locationNo 지역번호를 받아올 시 그 지역만 조회하기 위해 변수에 담기
	String locationNo = request.getParameter("locationNo");
	// 디버깅
	System.out.println(locationNo + " <-- locationNo");
	
	
	// 수정할 guestbookNo 받아오기
	int guestbookNo = Integer.parseInt(request.getParameter("guestbookNo"));
	// 디버깅
	System.out.println(guestbookNo + " <-- guestbookNo");
	
	
	
	// ----------------------------------------------------------- 서비스
	// 1. DB 연동
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://localhost:3306/blog";
	String dbuser = "root";
	String dbpw = "1234";
	Connection conn = DriverManager.getConnection(url, dbuser, dbpw);
	// 디버깅
	System.out.println(conn + " <-- conn");
	
	
	
	
	// 2. 쿼리담기
	// 2-1왼쪽메뉴 목록 locationStmt locationRs
	String locationSql = "SELECT location_no locationNo, location_name locationName FROM location";
	PreparedStatement locationStmt = conn.prepareStatement(locationSql);
	// 디버깅
	System.out.println(locationStmt + " <-- locationStmt");
	
	// 쿼리실행
	ResultSet locationRs = locationStmt.executeQuery();
	
	
	
	// 2-2방명록 수정
	String updateSql = "SELECT guestbook_no guestbookNo, guestbook_content guestbookContent, create_date createDate FROM guestbook WHERE guestbook_no = ?";
	PreparedStatement updateStmt = conn.prepareStatement(updateSql);
	// ? setter
	updateStmt.setInt(1, guestbookNo);
	
	// 쿼리실행
	ResultSet updateRs = updateStmt.executeQuery();
	
	
	// ----------------------------------------------------------- 뷰
%>

	
<div class="container">
	<h1 class="container p-3 my-3 border"><a href="./index.jsp">BLOG</a></h1>
	<div class="row">
		<div class="col-sm-2">
			<!-- left menu -->
			<!-- location DB를 메뉴 형태로 보여줄 거임 -->
			<div>	
				<ul class="list-group">
					<li class="list-group-item"><a href="./index.jsp">HOME</a></li>
					<li class="list-group-item"><a href="./diary.jsp">DIARY</a></li>
					<li class="list-group-item"><a href="./guestbook.jsp">방명록</a></li>
					<li class="list-group-item"><a href="./boardList.jsp">전체</a></li>
					<%
						while(locationRs.next()){
					%>
							<li class="list-group-item">
								<a href="./boardList.jsp?locationNo=<%=locationRs.getInt("locationNo")%>">
									<%=locationRs.getString("locationName")%>
								</a>
							</li>
					<%
						}
					%>
				</ul>
			</div>
		</div><!-- end col-sm-2 -->
		
		<div class="col-sm-10">
			<form action="./updateGuestbookAction.jsp" method="post">
				<table class="table table-hover table-striped">
					<%
						if(updateRs.next()){
					%>
						<tr>
							<th>NO</th>
							<td>
								<input type="text" name="guestbookNo" value="<%=updateRs.getInt("guestbookNo")%>" class="form-control" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th>CONTENT</th>
							<td>
								<textarea rows="2" cols="50" name="guestbookContent" class="form-control"><%=updateRs.getString("guestbookContent")%></textarea>
							</td>
						</tr>
						<tr>
							<th>CREATEDATE</th>
							<td><input type="text" name="createDate" value="<%=updateRs.getString("createDate")%>" class="form-control" readonly="readonly"></td>
						</tr>
					<%
						}
					%>
				</table>
				<button type="submit" class="btn btn-outline-light text-dark">수정</button>
			</form>
		</div><!-- end col-sm-10 -->
	</div><!-- end row -->
</div><!-- end 전체 div -->
</body>
</html>
<%				
	// DB 자원해제 
	updateRs.close();
	updateStmt.close();
	locationRs.close();
	locationStmt.close();
	conn.close();
%>