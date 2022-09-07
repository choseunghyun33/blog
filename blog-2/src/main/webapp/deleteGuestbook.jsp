<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
	// 로그인이 안되어 있는 경우 재요청
	if(session.getAttribute("loginId") == null) {
		response.sendRedirect("./index.jsp");
		return;
	}
	
	if(request.getParameter("guestbookNo") == null) {
		response.sendRedirect("./guestbook.jsp");
		return;
	}
	
	// 삭제할 no받아오기
	int guestbookNo = Integer.parseInt(request.getParameter("guestbookNo"));
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
	// stmt
	String sql = "DELETE FROM guestbook where guestbook_no = ? and id = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, guestbookNo);
	stmt.setString(2, (String)session.getAttribute("loginId"));
	// 디버깅
	System.out.println(stmt + " <-- stmt");
	
	
	// 3. 실행
	int row = stmt.executeUpdate();
	// 디버깅
	if(row == 1){
		System.out.println("방명록삭제성공!!!");
	} else {
		System.out.println("방명록삭제실패!!!");
	}
	
	
	// 4. 재요청
	response.sendRedirect("./guestbook.jsp");
	
	
	// 5. 자원해제
	stmt.close();
	conn.close();
%>