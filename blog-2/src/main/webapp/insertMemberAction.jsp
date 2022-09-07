<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	// 인코딩
	request.setCharacterEncoding("UTF-8");


	// 재요청 - 접근 막기
	if(session.getAttribute("loginId") != null){ // 로그인된 사람 막기
		response.sendRedirect("./index.jsp"); // 페이지 재요청
		return;
	}

	// 값받기
	String id = request.getParameter("id");
	String pw = request.getParameter("pw");
	// 잘못된값이 들어왔을 때 멈추기
	if(id == null || pw == null || id.length() < 4 || pw.length() < 4){
		response.sendRedirect("./insertMember.jsp?errorMsg=error");		
		return; // return 대신 else 블록을 사용해도 된다.
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
	String sql = "INSERT INTO member(id, pw) VALUES (?, PASSWORD(?))";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, id);
	stmt.setString(2, pw);
	// 디버깅
	System.out.println(stmt + " <-- stmt");
	
	// 쿼리실행
	ResultSet rs = stmt.executeQuery();
	
	
	// 재요청
	response.sendRedirect("./index.jsp");
	
	// DB자원해제
	stmt.close();
	conn.close();
%>