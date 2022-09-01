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
	// ----------------------------------------------------------- 컨트롤러
	// locationNo 지역번호를 받아올 시 그 지역만 조회하기 위해 변수에 담기
	String locationNo = request.getParameter("locationNo");
	// 디버깅
	System.out.println(locationNo + " <-- locationNo");
	
	// 페이징
	int currentPage = 1; // 현재페이지가 없으면 항상 1
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	final int ROW_PER_PAGE = 10;
	int beginRow = (currentPage - 1) * ROW_PER_PAGE;
	// 디버깅
	System.out.println(beginRow + " <-- beginRow");
	
	
	
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
	
	// 2-2페이지 lastPageStmt lastPageRs
	// lastPage
	int lastPage = 0;
	String lastPageSql = "SELECT count(*) from guestbook";
	PreparedStatement lastPageStmt = conn.prepareStatement(lastPageSql);
	ResultSet lastPageRs = lastPageStmt.executeQuery();
	if(lastPageRs.next()){
		lastPage = lastPageRs.getInt("count(*)");
	}
	
	
	
	String guestbookSql = "SELECT guestbook_no guestbookNo, guestbook_content guestbookContent, id, create_date createDate FROM guestbook ORDER BY guestbook_no DESC limit ?,?";
	PreparedStatement guestbookStmt = conn.prepareStatement(guestbookSql);
	guestbookStmt.setInt(1, beginRow);
	guestbookStmt.setInt(2, ROW_PER_PAGE);
	ResultSet guestbookRs = guestbookStmt.executeQuery();
	
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
				if(session.getAttribute("loginId") != null){
			%>		
				<form method="post" action="./insertGuestbookAction.jsp">
					<div>
						<textarea rows="3" cols="50" name="guestbookContent" class="form-control"></textarea>
					</div>	
					<div>
						<button type="submit" class="btn btn-outline-light text-dark">입력</button>
					</div>
					<hr>
					<!-- 
						guestbook_no : auto increment
						guestbook_content : guestbookContent
						id : session.getAttribute("loginId")
						create_date : now()
					-->
				</form>
			<%	
				}
			%>
			
				<table class="table table-hover table-striped">
					<%
						while(guestbookRs.next()){
					%>
							<tr>
								<td colspan="3"><%=guestbookRs.getString("guestbookContent")%></td>
							</tr>
							<tr>
								<td><%=guestbookRs.getString("id")%></td>
								<td><%=guestbookRs.getString("createDate")%></td>
								<td>
									<%
										String loginId = (String)session.getAttribute("loginId");
										if(loginId != null && loginId.equals(guestbookRs.getString("id"))){
									%>
											<a href="./updateGuestbook.jsp?guestbookNo=<%=guestbookRs.getInt("guestbookNo")%>">수정</a>
											<a href="./deleteGuestbook.jsp?guestbookNo=<%=guestbookRs.getInt("guestbookNo")%>">삭제</a>
									<%	
										}
									%>
								</td>
							</tr>
					<%		
						}
					%>
				</table>
				<!-- 페이징 -->
				<div>
					<ul class="pagination pagination-sm">
					<%
						if(currentPage < 1){
					%>	
							<li><a href="./guestbook.jsp?currentPage=<%=currentPage-1%>">이전</a></li>
					<%	
						}
					%>
					<%
						if(currentPage > lastPage){
					%>	
							<li><a href="./guestbook.jsp?currentPage=<%=currentPage+1%>">다음</a></li>
					<%	
						}
					%>
					</ul>
				</div>
		</div><!-- end col-sm-10 -->
	</div><!-- end row -->
</div><!-- end 전체 div -->
</body>
</html>
<%				
	// DB 자원해제 
	lastPageRs.close();
	lastPageStmt.close();
	guestbookRs.close();
	guestbookStmt.close();
	locationRs.close();
	locationStmt.close();
	conn.close();
%>