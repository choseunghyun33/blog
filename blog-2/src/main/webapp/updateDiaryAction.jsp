<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
	// 인코딩
	request.setCharacterEncoding("UTF-8");


	//관리자 외 재요청
	if(session.getAttribute("loginLevel") == null // level이 null이거나
		|| (Integer)session.getAttribute("loginLevel") < 0){ // level이 0보다 작다면
		response.sendRedirect("./diary.jsp?errorMsg=No permission"); // 재요청
		return;
	}
	
	// 수정할 diaryNo
	int diaryNo = Integer.parseInt(request.getParameter("diaryNo"));
	// 수정할 내용
	String diaryDate = request.getParameter("diaryDate");
	String diaryTodo = request.getParameter("diaryTodo");
	
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	String driver = "org.mariadb.jdbc.Driver";
	String url = "jdbc:mariadb://localhost:3306/blog";
	String id = "root";
	String pw = "1234";
	
	// 1. DB 연동
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(url,id,pw);
	// 디버깅
	System.out.println(conn + " <-- conn");
	
	
	
	// 2. 쿼리담기
	String sql = "UPDATE diary SET diary_date = ?, diary_todo = ? WHERE diary_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	// ? setter
	stmt.setString(1, diaryDate);
	stmt.setString(2, diaryTodo);
	stmt.setInt(3, diaryNo);
	// 디버깅
	System.out.println(stmt + " <-- stmt");
	
	// 3. 쿼리실행
	// 4. 재요청
	int row = stmt.executeUpdate();
	// 디버깅
	if(row == 1){ // delete 성공
		System.out.println("delete 성공!!");
		response.sendRedirect("./diary.jsp");
	} else {
		System.out.println("delete 실패!!");
		response.sendRedirect("./diary.jsp?errorMsg=delete fail");
	}
	
	// 5. 닫기
	stmt.close();
	conn.close();
%>