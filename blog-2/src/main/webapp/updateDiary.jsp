<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>BOARDLIST</title>
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


	//관리자 외 재요청
	if(session.getAttribute("loginLevel") == null // level이 null이거나
		|| (Integer)session.getAttribute("loginLevel") < 0){ // level이 0보다 작다면
		response.sendRedirect("./diary.jsp?errorMsg=No permission"); // 재요청
		return;
	}
	
	
	// ----------------------------------------------------------- 컨트롤러
	// locationNo 지역번호를 받아올 시 그 지역만 조회하기 위해 변수에 담기
	String locationNo = request.getParameter("locationNo");
	// 디버깅
	System.out.println(locationNo + " <-- locationNo");
	
	
	
	// 받아온 diaryNo
	int diaryNo = Integer.parseInt(request.getParameter("diaryNo"));

	
	
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
	
	// 2-2diary
	String diarySql = "SELECT diary_date diaryDate, diary_todo diaryTodo, create_date createDate FROM diary WHERE diary_no = ?";
	PreparedStatement diaryStmt = conn.prepareStatement(diarySql);
	// ? setter
	diaryStmt.setInt(1, diaryNo);
	// 디버깅
	System.out.println(diaryStmt + " <-- stmt");
	
	// 3. 쿼리실행
	ResultSet diaryRs = diaryStmt.executeQuery();
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
			<%
				if(diaryRs.next()){
			%>
			<form action="./updateDiaryAction.jsp" method="post">
				<input type="hidden" name="diaryNo" value="<%=diaryNo%>">
				<table class="table table-hover table-striped">
					<tr>
						<th>날짜</th>
						<td><input type="text" name="diaryDate" value="<%=diaryRs.getString("diaryDate")%>" placeholder="0000-00-00" class="form-control"></td>
					</tr>
					<tr>
						<th>TODO</th>
						<td><input type="text" name="diaryTodo" value="<%=diaryRs.getString("diaryTodo")%>" class="form-control"></td>
					</tr>
					<tr>
						<th>createDate</th>
						<td><%=diaryRs.getString("createDate")%></td>
					</tr>
				</table>
				<button type="submit" class="btn btn-outline-light text-dark">수정</button>
			</form>
			<%
				}
			%>
		</div><!-- end col-sm-10 -->
	</div><!-- end row -->
</div><!-- end 전체 div -->
</body>
</html>
<%				
	// DB 자원해제 
	diaryRs.close();
	diaryStmt.close();
	locationRs.close();
	locationStmt.close();
	conn.close();
%>