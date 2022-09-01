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
	//인코딩
	request.setCharacterEncoding("UTF-8");


	// 재요청 - 접근 막기
	if(session.getAttribute("loginId") == null){ // 로그인안된 사람이 진행되면 안되므로
		response.sendRedirect("./index.jsp?errorMsg=do login");	// 재요청후에
		return; 								// 리턴
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
	
	
	// 2-3댓글리스트
	String commentSql = "SELECT comment_no commentNo, comment_content commentContent, create_date createDate, id FROM comment where board_no = ? order by comment_no desc";
	PreparedStatement commentStmt = conn.prepareStatement(commentSql);
	// ? setter
	commentStmt.setInt(1, boardNo);
	
	// 쿼리실행
	ResultSet commentRs = commentStmt.executeQuery();
	
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
				if(oneRs.next()){
			%>
					<table class="table table-hover table-striped">
						<tr>
							<th>location</th>
							<td><%=oneRs.getString("locationName")%></td>
						</tr>
						<tr>
							<th>boardTitle</th>
							<td><%=oneRs.getString("boardTitle")%></td>
						</tr>
						<tr>
							<th>boardContent</th>
							<td><%=oneRs.getString("boardContent")%></td>
						</tr>
						<tr>
							<th>createDate</th>
							<td><%=oneRs.getString("createDate")%></td>
						</tr>
					</table>
			<%
				}
				// 관리자 제외 막기
				if((Integer)session.getAttribute("loginLevel") > 0){
			%>
					<a href="./updateBoard.jsp?boardNo=<%=boardNo%>" class="btn btn-outline-light text-dark">수정</a>
					<a href="./deleteBoard.jsp?boardNo=<%=boardNo%>" class="btn btn-outline-secondary">삭제</a>
			<%
				}
			%>
			<br/>
			<br/>
			<!-- 댓글입력 -->
			<form action="./insertCommentAction.jsp" method="post">
				<input type="hidden" name="boardNo" value="<%=boardNo%>">
				<table class="table table-hover table-striped">
					<tr>
						<th>CONTENT</th>
						<td>
							<textarea rows="2" cols="50" class="form-control" name="commentContent"></textarea>
						</td>
					</tr>
				</table>
				<button type="submit" class="btn btn-outline-secondary">댓글생성</button>
			</form>
			<br/>
			<br/>
			<!-- 댓글LIST 보이기 -->
			<table class="table table-hover table-striped">
				<tr>
					<th>NO</th>
					<th>CONTENT</th>
					<th>CREATEDATE</th>
					<th>수정/삭제</th>
				</tr>
				<%
					while(commentRs.next()){
				%>
					<tr>
						<td><%=commentRs.getInt("commentNo")%></td>
						<td><%=commentRs.getString("commentContent")%></td>
						<td><%=commentRs.getString("createDate")%></td>
						<td>
							<%
								String loginId = (String)session.getAttribute("loginId");
								if(loginId != null && loginId.equals(commentRs.getString("id"))){
							%>
									<a href="./updateComment.jsp?boardNo=<%=boardNo%>&commentNo=<%=commentRs.getInt("commentNo")%>">수정</a>
									<a href="./deleteCommentAction.jsp?boardNo=<%=boardNo%>&commentNo=<%=commentRs.getInt("commentNo")%>">삭제</a>
							<%		
								}
							%>
							
						</td>
					</tr>
				<%
					}
				%>
			</table>
		</div><!-- end col-sm-10 -->
	</div><!-- end row -->
</div><!-- end 전체 div -->
</body>
</html>
<%				
	// DB 자원해제 
	commentRs.close();
	commentStmt.close();
	locationRs.close();
	locationStmt.close();
	oneRs.close();
	oneStmt.close();
	conn.close();
%>