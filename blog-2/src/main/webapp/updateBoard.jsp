<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>UPDATEBOARD</title>
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
		response.sendRedirect("./boardList.jsp?errorMsg=No permission"); // 재요청
		return;
	}
	
	// ----------------------------------------------------------- 컨트롤러
	// locationNo 지역번호를 받아올 시 그 지역만 조회하기 위해 변수에 담기
	String locationNo = request.getParameter("locationNo");
	// 디버깅
	System.out.println(locationNo + " <-- locationNo");
	
	
	// boardNo 입력값 받기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	// 디버깅
	System.out.println(boardNo + " <-- boardNo");
	
	
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
	

	// 2-2상세보기 oneStmt oneRs
	String oneSql = "SELECT location_name locationName, board_title boardTitle, board_content boardContent, b.create_date createDate FROM location INNER JOIN board b USING(location_no) where board_no = ?";
	PreparedStatement oneStmt = conn.prepareStatement(oneSql);
	// ? setter
	oneStmt.setInt(1, boardNo);
	
	// 쿼리실행
	ResultSet oneRs = oneStmt.executeQuery();
	
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
			<form action="./updateBoardAction.jsp" method="post">
				<input type="hidden" name="boardNo" value="<%=boardNo%>">
			<% 
				if(oneRs.next()){
			%>
					<table class="table table-hover table-striped">
						<tr>
							<th>location</th>
							<td>
								<select name="locationNo" class="form-control">
									<%
										// 좋은방법은 아님
										locationRs.first();
										// do while은 한번 실행하고 조건문을 나중에 실행하기 때문에
										// 지금은 서울부터 보여주기 위해 do while로 진행
										do {
									%>
											<option value="<%=locationRs.getString("locationNo")%>">
												<%=locationRs.getString("locationName")%>
											</option>
									<%	
										} while(locationRs.next());
									%>
								</select>
							</td>
							</tr>
						<tr>
							<th>boardTitle</th>
							<td>
								<input type="text" name="boardTitle" class="form-control" value="<%=oneRs.getString("boardTitle")%>">
							</td>
						</tr>
						<tr>
							<th>boardContent</th>
							<td>
								<textarea  rows="5" cols="50" name="boardContent" class="form-control">
									<%=oneRs.getString("boardContent")%>
								</textarea>
							</td>
						</tr>
						<tr>
							<th>createDate</th>
							<td>
								<input type="text" name="createDate" class="form-control" value="<%=oneRs.getString("createDate")%>" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th>password</th>
							<td>
								<input type="password" name="boardPw" class="form-control">
							</td>
						</tr>
					</table>
			<%
				}
			%>
				<button type="submit" class="btn btn-outline-light text-dark">수정</button>
			</form>
		</div><!-- end col-sm-10 -->
	</div><!-- end row -->
</div><!-- end 전체 div -->
</body>
</html>
<%				
	// DB 자원해제 
	oneRs.close();
	oneStmt.close();
	locationRs.close();
	locationStmt.close();
	conn.close();
%>