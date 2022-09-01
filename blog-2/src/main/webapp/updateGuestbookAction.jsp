<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
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
	
	// 내용이 없을 시 재요청
	if(request.getParameter("guestbookContent") == null || request.getParameter("guestbookContent").length() < 1) {
		response.sendRedirect("./guestbook.jsp");
		return;
	}
	
	// 수정할 no받아오기
	int guestbookNo = Integer.parseInt(request.getParameter("guestbookNo"));
	String guestbookContent = request.getParameter("guestbookContent");
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
	// stmt
	String sql = "UPDATE guestbook SET guestbook_content = ? where guestbook_no = ? and id = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, guestbookContent);
	stmt.setInt(2, guestbookNo);
	stmt.setString(3, (String)session.getAttribute("loginId"));
	// 디버깅
	System.out.println(stmt + " <-- stmt");
	
	
	// 3. 실행
	int row = stmt.executeUpdate();
	// 디버깅
	if(row == 1){
		System.out.println("방명록수정성공!!!");
	} else {
		System.out.println("방명록수정실패!!!");
	}
	
	
	// 4. 재요청
	response.sendRedirect("./guestbook.jsp");
	
	
	// 5. 자원해제
	stmt.close();
	conn.close();
%>