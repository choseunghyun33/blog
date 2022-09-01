<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%	
	//인코딩
	request.setCharacterEncoding("UTF-8");


	// 주소창으로 바로 갈 수 있기 때문에 Action페이지도 막아야한다
	if(session.getAttribute("loginId") == null || (Integer)session.getAttribute("loginLevel") < 1){
		response.sendRedirect("./index.jsp");
		return;
	}
	/*
	if((Integer)session.getAttribute("loginLevel") < 1){
		response.sendRedirect("./boardList.jsp");
		return;
	}	
	*/
	
	// ------------------------------------- 컨트롤러
	// 입력값 받아오기
	int locationNo = Integer.parseInt(request.getParameter("locationNo"));
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	String boardPw = request.getParameter("boardPw");
	// 디버깅
	System.out.println(locationNo + " <-- locationNo");
	System.out.println(boardTitle + " <-- boardTitle");
	System.out.println(boardContent + " <-- boardContent");
	System.out.println(boardPw + " <-- boardPw");


	
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
	String sql = "INSERT INTO board (location_no, board_title, board_content, board_pw, create_date) VALUES (?, ?, ?, PASSWORD(?), now())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	// ? setter
	stmt.setInt(1,locationNo);
	stmt.setString(2,boardTitle);
	stmt.setString(3,boardContent);
	stmt.setString(4,boardPw);
	// 디버깅
	System.out.println(stmt + " <-- stmt");


	
	// 3. 쿼리실행
	int row = stmt.executeUpdate();
	// 디버깅
	if(row == 1){ // insert성공
		System.out.println("글생성성공!!");
	} else { // insert실패
		System.out.println("글생성실패!!");
	}


	
	// 4. 재요청
	// boardList로 돌아가기
	response.sendRedirect("./boardList.jsp");
	// ----------------------------------------------------------- 뷰
	
	
	
	// 5. DB자원해제
	stmt.close();
	conn.close();
%>