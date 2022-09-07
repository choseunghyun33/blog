<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
	// 인코딩
	request.setCharacterEncoding("UTF-8");


	//----------------------------------------------------------- 컨트롤러
	// 입력값 받기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String commentContent = request.getParameter("commentContent");
	// 디버깅
	System.out.println(boardNo + " <-- boardNo");
	System.out.println(commentContent + " <-- commentContent");
	System.out.println(session.getAttribute("loginId") + " <-- loginId");
	
	
	
	
	// 권한 없을 시 재요청
	if(session.getAttribute("loginId") == null){
		response.sendRedirect("./index.jsp"); 
		return;
	}
	
	// 댓글 내용이 없을 시 재요청
	if(commentContent == null || commentContent.length() < 1){
		response.sendRedirect("./boardOne.jsp?boardNo=" + boardNo); 
		return;
	}
	
	//----------------------------------------------------------- 서비스
	// 1. DB 연동
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://3.34.240.0:3306/blog";
	String dbuser = "root";
	String dbpw = "1234";
	Connection conn = DriverManager.getConnection(url, dbuser, dbpw);
	// 디버깅
	System.out.println(conn + " <-- conn");
	
	
	// 2. 쿼리담기 stmt
	String sql = "insert into comment (board_no, comment_content, id, create_date) values (?, ?, ?, now())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	// ? setter
	stmt.setInt(1, boardNo);
	stmt.setString(2, commentContent);
	stmt.setString(3, (String)session.getAttribute("loginId"));
	// 디버깅
	System.out.println(stmt + " <-- stmt");
	
	// 쿼리실행
	int row = stmt.executeUpdate();
	// 디버깅
	if(row == 1){ // 댓글생성성공
		System.out.println("댓글생성성공!!!");
	} else { // 댓글생성실패
		System.out.println("댓글생성실패!!!");
	}
	
	// 재요청
	response.sendRedirect("./boardOne.jsp?boardNo=" + boardNo);
	
	// DB자원해제
	stmt.close();
	conn.close();
%>