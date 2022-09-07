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
    color: black;
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
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	final int ROW_PER_PAGE = 10;
	int beginRow = (currentPage - 1) * ROW_PER_PAGE;
	// 디버깅
	System.out.println(beginRow + " <-- beginRow");
	
	
	
	// 검색
	String word = request.getParameter("word");
	// 디버깅
	System.out.println(word + " <-- word");
	
	
	
	// ----------------------------------------------------------- 서비스
	// 1. DB 연동
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://3.34.240.0:3306/blog";
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
	

	// 게시글 목록
	String boardSql = "";
	PreparedStatement boardStmt = null;
	
	
	
	// 2-2메인메뉴 목록 boardStmt boardRs
	if(locationNo == null && word == null){ // 지역번호와 검색이 없을때
		/*
		SELECT l.location_name locationName, b.location_no locationNo, b.board_no boardNo, b.board_title boardTitle 
		FROM board b INNER JOIN location l
		ON l.location_no = b.location_no
		ORDER BY board_no DESC;
		*/
		boardSql = "SELECT location_name locationName, location_no locationNo, board_no boardNo, board_title boardTitle FROM board INNER JOIN location USING(location_no) ORDER BY board_no DESC limit ?, ?"; 
		boardStmt = conn.prepareStatement(boardSql);
		// boardStmt setter
		boardStmt.setInt(1, beginRow);
		boardStmt.setInt(2, ROW_PER_PAGE);
	} else if(locationNo != null && word == null){ // 지역번호는 있고 검색이 없을때
		boardSql = "SELECT location_name locationName, location_no locationNo, board_no boardNo, board_title boardTitle FROM board INNER JOIN location USING(location_no) WHERE location_no = ? ORDER BY board_no DESC limit ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		// boardStmt setter
		boardStmt.setInt(1, Integer.parseInt(locationNo)); 
		boardStmt.setInt(2, beginRow);
		boardStmt.setInt(3, ROW_PER_PAGE);
	} else if(locationNo == null && word != null) { // 검색이 있을때
		boardSql = "SELECT location_name locationName, location_no locationNo, board_no boardNo, board_title boardTitle FROM board INNER JOIN location USING(location_no) WHERE board_title LIKE ? ORDER BY board_no DESC LIMIT ?,?";
		boardStmt = conn.prepareStatement(boardSql);
		// ? 담기
		boardStmt.setString(1,"%" + word + "%"); // 1번째 ? board_title LIKE
		boardStmt.setInt(2, beginRow);			// 2번째 ? beginRow
		boardStmt.setInt(3, ROW_PER_PAGE);		// 3번째 ? ROW_PER_PAGE
	} else if(locationNo != null && word != null) { // 지역번호내에서 검색
		boardSql = "SELECT location_name locationName, location_no locationNo, board_no boardNo, board_title boardTitle FROM board INNER JOIN location USING(location_no) WHERE location_no = ? and board_title LIKE ? ORDER BY board_no DESC limit ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		// boardStmt setter
		boardStmt.setInt(1, Integer.parseInt(locationNo)); 	// 1번째 ? 지역번호
		boardStmt.setString(2,"%" + word + "%"); 			// 2번째 ? board_title LIKE
		boardStmt.setInt(3, beginRow);						// 3번째 ? beginRow
		boardStmt.setInt(4, ROW_PER_PAGE);					// 4번째 ? ROW_PER_PAGE
	}
	
	ResultSet boardRs = boardStmt.executeQuery();
	
	
	// 2-3마지막페이지 totalRowStmt totalRowRs
	// 마지막페이지 구하기
	int totalRow = 0;
	int lastPage = 0;
	PreparedStatement totalRowStmt = null;
	String totalRowSql = "";
	if(locationNo == null && word == null){ // 지역번호와 검색이 없을때
		totalRowSql = "SELECT count(*) from board";
		totalRowStmt = conn.prepareStatement(totalRowSql);
	} else if(locationNo != null && word == null){ // 지역번호는 있고 검색이 없을때
		totalRowSql = "SELECT count(*) from board where location_no = ?";
		totalRowStmt = conn.prepareStatement(totalRowSql);
		totalRowStmt.setInt(1,Integer.parseInt(locationNo));
	} else if(locationNo == null && word != null){ // 검색이 있을때
		totalRowSql = "SELECT count(*) from board where board_title like ?";
		totalRowStmt = conn.prepareStatement(totalRowSql);
		totalRowStmt.setString(1,"%" + word + "%");
	} else if(locationNo != null && word != null){ // 지역번호내에서 검색
		totalRowSql = "SELECT count(*) from board where location_no = ? and board_title like ?";
		totalRowStmt = conn.prepareStatement(totalRowSql);
		totalRowStmt.setInt(1,Integer.parseInt(locationNo));
		totalRowStmt.setString(2,"%" + word + "%");
	}
	
	
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("count(*)");
	}
	
	lastPage = (int)Math.ceil((double)totalRow / ROW_PER_PAGE);
	
	// 번호페이징
	int startPage = ((currentPage - 1) / ROW_PER_PAGE) * ROW_PER_PAGE + 1;
	int endPage = startPage - 1 + ROW_PER_PAGE;
	// 마지막페이징 설정
	if(endPage > lastPage){ // 번호페이징 마지막페이지가 끝페이지보다 클 경우 마지막페이지를 끝페이지로 설정한다
		endPage = lastPage;
	}
	
	
	// ----------------------------------------------------------- 뷰
%>

	
<div class="container">
	<h1 class="container p-3 my-3 border">BLOG</h1>
	<div class="row">
		<div class="col-sm-2">
			<!-- left menu -->
			<!-- location DB를 메뉴 형태로 보여줄 거임 -->
			<div>	
				<ul class="list-group">
					<li class="list-group-item"><a href="./insertBoardForm.jsp">등록</a></li>
					<li class="list-group-item"><a href="./boardList2.jsp">전체</a></li>
					<%
						while(locationRs.next()){
					%>
							<li class="list-group-item">
								<a href="./boardList2.jsp?locationNo=<%=locationRs.getInt("locationNo")%>">
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
			<!-- main menu -->
			<!-- locationNo이 있는가 없는가 분기 -->
			<table class="table table-hover table-striped">
				<thead>
					<tr>
						<th>locationName</th>
						<th>boardNo</th>
						<th>boardTitle</th>
					</tr>
				</thead>
				<tbody>
					<%
						while(boardRs.next()){
					%>
							<tr>
								<td><%=boardRs.getString("locationName")%></td>
								<td><%=boardRs.getInt("boardNo")%></td>
								<td><a href="boardOne.jsp?boardNo=<%=boardRs.getInt("boardNo")%> "><%=boardRs.getString("boardTitle")%></a></td>
							</tr>
					<%			
						} 
					%>	
						
					
				</tbody>
			</table>
			
			<div class="form-group">
				<form class="form-inline justify-content-center" action="./boardList2.jsp" method="get">
					<%
						if(locationNo != null){	// 지역번호가 있을경우
					%>
							<input type="hidden" name="locationNo" value="<%=locationNo%>">
					<%		
						}
					%>
		               	<label>제목 :		</label>
		               	<input type="text" class="form-control" name="word">
		               	<button type="submit" class="btn btn-outline-light text-dark">검색</button>
            	</form>
			</div>
			
			<!-- 페이징 -->
			<div>
				<ul class="pagination pagination-sm justify-content-center">
				<%
					if(locationNo == null && word == null){ // 지역번호와 검색이 없을때
						if(currentPage > 1){ // 현재페이지가 1보가 클때만 '이전'
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage-1%>">이전</a></li>
				<%
						}
					} else if(locationNo != null && word == null) { // 지역번호만 있을때
						if(currentPage > 1){
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage-1%>&locationNo=<%=locationNo%>">이전</a></li>
				<%			
						}
					} else if(locationNo == null && word != null){ // 검색만 있을때
						if(currentPage > 1){
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage-1%>&word=<%=word%>">이전</a></li>
				<%				
						}
					} else if(locationNo != null && word != null){ // 지역번호 검색 둘 다 있을때
						if(currentPage > 1){
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage-1%>&locationNo=<%=locationNo%>&word=<%=word%>">이전</a></li>
				<%				
						}
					}
				%>
				<%				
					// 번호페이징 반복문
					for(int i = startPage; i <= endPage; i++){
						if(locationNo == null && word == null){ // 지역번호와 검색이 없을때
							if(i == currentPage){ // 현재페이지일 경우 두껍게 표시
				%>
								<li class="page-item"><b class="page-link"><%=i%></b></li>
				<%					
							} else {
				%>
							<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=i%>"><%=i%></a></li>
				<%		
							}
						} else if(locationNo != null && word == null) { // 지역번호만 있을때
							if(i == currentPage){ // 현재페이지일 경우 두껍게 표시
				%>
								<li class="page-item"><b class="page-link"><%=i%></b></li>
				<%					
							} else {
				%>

							<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=i%>&locationNo=<%=locationNo%>"><%=i%></a></li>
				<%		
							}
						} else if(locationNo == null && word != null){ // 검색만 있을때
							if(i == currentPage){ // 현재페이지일 경우 두껍게 표시
				%>
								<li class="page-item"><b class="page-link"><%=i%></b></li>
				<%					
							} else {
				%>
							<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=i%>&word=<%=word%>"><%=i%></a></li>
				<%			
							}
						} else if(locationNo != null && word != null){ // 지역번호 검색 둘 다 있을때
							if(i == currentPage){ // 현재페이지일 경우 두껍게 표시
				%>
								<li class="page-item"><b class="page-link"><%=i%></b></li>
				<%					
							} else {
				%>
							<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=i%>&locationNo=<%=locationNo%>&word=<%=word%>"><%=i%></a></li>
				<%			
							}
						}
					}
				%>
				
				<%
					if(locationNo == null && word == null){ // 지역번호와 검색이 없을때
						if(currentPage < lastPage){ // 마지막페이지보다 현재페이지가 작을때만 '다음'
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage+1%>">다음</a></li>
				<%
						}
					} else if(locationNo != null && word == null) { // 지역번호만 있을때
						if(currentPage < lastPage){
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage+1%>&locationNo=<%=locationNo%>">다음</a></li>
				<%			
						}
					} else if(locationNo == null && word != null){ // 검색만 있을때
						if(currentPage < lastPage){
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage+1%>&word=<%=word%>">다음</a></li>
				<%				
						}
					} else if(locationNo != null && word != null){ // 지역번호 검색 둘 다 있을때
						if(currentPage < lastPage){
				%>
						<li class="page-item"><a class="page-link" href="./boardList2.jsp?currentPage=<%=currentPage+1%>&locationNo=<%=locationNo%>&word=<%=word%>">다음</a></li>
				<%				
						}
					}
				%>
				</ul>
			</div><!-- end 페이징 -->
		</div><!-- end col-sm-10 -->
	</div><!-- end row -->
</div><!-- end 전체 div -->
</body>
</html>
<%				
	// DB 자원해제
	// locationStmt locationRs boardStmt boardRs totalRowStmt totalRowRs 
	locationRs.close();
	locationStmt.close();
	boardRs.close();
	boardStmt.close();
	totalRowRs.close();
	totalRowStmt.close();
	conn.close();
%>