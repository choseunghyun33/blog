<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*"%>
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
.mydiary a {
	color: skyblue;
}
.mydiv {
	padding-left: 38%;
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
	
	
	// 달력
	Calendar c = Calendar.getInstance();
	
	// 날짜 있으면 날짜 가져오기
	if(request.getParameter("y") != null && request.getParameter("m") != null){
		// 있으면 받기
		int y = Integer.parseInt(request.getParameter("y"));
		int m = Integer.parseInt(request.getParameter("m"));
		
		// 0월 13월 나오지 않게 조건
		if(m == -1){ // 만약 0월이라면 (1월에서 이전누를경우)
			m = 12; // 12월로 만들기
			y -= 1; // -1년
		}
		if(m == 12){ // 만약 13월이라면 (12월에서 다음누를경우)
			m = 0; // 1월로 만들기
			y += 1; // +1년
		}
		
		// 날짜 setter
		c.set(Calendar.YEAR, y);
		c.set(Calendar.MONTH, m);
	}
	
	// 해당 월 마지막날짜
	int lastDay = c.getActualMaximum(Calendar.DATE);
	
	// 시작블록 : 첫줄의 생기는 블록
	// 구해야 하는 것 : 해당 월 1일의 요일
	Calendar first = Calendar.getInstance();
	first.set(Calendar.YEAR, c.get(Calendar.YEAR));
	first.set(Calendar.MONTH, c.get(Calendar.MONTH));
	first.set(Calendar.DATE, 1);
	
	int startBlank = first.get(Calendar.DAY_OF_WEEK) - 1;
	
	
	// 끝블록 : 마지막줄의 생기는 블록
	int endBlank = 7 - (startBlank + lastDay) % 7;
	// 7일 경우 0으로 만들기 -> 빈칸7개는 필요없음
	if(endBlank == 7){
		endBlank = 0;
	}
	
	
	
	
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
	
	
	
	// 2-2diary
	String diarySql = "SELECT diary_no diaryNo, diary_date diaryDate, diary_todo diaryTodo FROM diary WHERE YEAR(diary_date) = ? AND MONTH(diary_date) = ? ORDER BY diary_date";
	PreparedStatement diaryStmt = conn.prepareStatement(diarySql);
	diaryStmt.setInt(1, c.get(Calendar.YEAR));
	diaryStmt.setInt(2, c.get(Calendar.MONTH) + 1);
	ResultSet diaryRs = diaryStmt.executeQuery();
	ArrayList<Diary> list = new ArrayList<Diary>();
	while(diaryRs.next()){
		Diary d = new Diary(); // 행의 수 만큼 객체를 만들어야한다.
		d.diaryNo = diaryRs.getInt("diaryNo");
		d.diaryDate = diaryRs.getString("diaryDate");
		d.diaryTodo = diaryRs.getString("diaryTodo");
		// 리스트에 담아주기
		list.add(d);
	}
	
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
		
		<div class="col-sm-10 mydiary">
		<%
			if(request.getParameter("errorMsg") != null){
		%>
				<span style="color:red"><%=request.getParameter("errorMsg")%></span>
		<%		
			}
		%>
			<!-- 달력 페이징 -->
			<div class="mydiv">
				<ul class="pagination pagination-sm">	
					<li class="page-item"><a class="page-link" href="./diary.jsp?y=<%=c.get(Calendar.YEAR)%>&m=<%=c.get(Calendar.MONTH)-1%>">이전달</a></li>
					<li class="page-item"><%=c.get(Calendar.YEAR)%>년 <%=c.get(Calendar.MONTH)+1%>월</li>
					<li class="page-item"><a class="page-link" href="./diary.jsp?y=<%=c.get(Calendar.YEAR)%>&m=<%=c.get(Calendar.MONTH)+1%>">다음달</a></li>
				</ul>
			</div>
			<!-- end 달력 페이징 -->
			<table class="table table-hover table-striped">
				<thead>
					<tr class="text-center">
						<th>일</th>
						<th>월</th>
						<th>화</th>
						<th>수</th>
						<th>목</th>
						<th>금</th>
						<th>토</th>
					</tr>
				</thead>
				<tbody>
					<tr>
					<%	
						for(int i = 1; i <= startBlank + lastDay + endBlank; i++){
							if(i - startBlank < 1){ // 1보다 작거나
					%>
								<td>&nbsp;</td>	
					<%					
							} else if(i - startBlank > lastDay){ // 마지막일보다 크다면
					%>
								<td>&nbsp;</td>	
					<%				
							} else { // 이때 a태그 안에 있는 c.get(Calendar.MONTH)+1 해주는 이유 !! -> DB에서는 0월x 1월부터 표기
					%>
								<td>
									<a href="./insertDiary.jsp?y=<%=c.get(Calendar.YEAR)%>&m=<%=c.get(Calendar.MONTH)+1%>&d=<%=i-startBlank%>">
										<%=i-startBlank%>
									</a>
									<%
										/*
											2022-07-27
											0123456789
										*/
										for(Diary d : list){
											int day = Integer.parseInt(d.diaryDate.substring(8));
											if(day == i-startBlank){
									%>
												<div>
													<a href="./diaryOne.jsp?diaryNo=<%=d.diaryNo%>"><%=d.diaryTodo%></a>
												</div>
									<%		
											}
										}
									%>
								</td>	
					<%						
							}
							if(i % 7 == 0){
					%>
							</tr><tr>
					<%			
							}
						}
					%>
					</tr>
				</tbody>
			</table>			
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