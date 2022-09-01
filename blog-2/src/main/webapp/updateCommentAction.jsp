<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	// 인코딩
	request.setCharacterEncoding("UTF-8");
	//----------------------------------------------------------- 컨트롤러
	// 수정할 boardNo commentNo commentPw 받아오기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	String commentContent = request.getParameter("commentContent");
	// 디버깅
	System.out.println(boardNo + " <-- boardNo");
	System.out.println(commentNo + " <-- commentNo");
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
	// 수정 stmt
	String sql = "UPDATE comment SET comment_content = ? WHERE board_no = ? AND comment_no = ? AND id = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	// ? setter
	stmt.setString(1, commentContent);
	stmt.setInt(2, boardNo);
	stmt.setInt(3, commentNo);
	stmt.setString(4, (String)session.getAttribute("loginId"));
	// 디버깅
	System.out.println(stmt + " <-- stmt");
	
	// 3. 쿼리실행
	int row = stmt.executeUpdate();
	// 디버깅
	if(row == 1){ // update 성공
		System.out.println("수정성공!!!");
	} else { // update 실패
		System.out.println("수정실패!!!");
	}
	
	// 4. 재요청
	response.sendRedirect("./boardOne.jsp?boardNo=" + boardNo);
	
	// 5. DB자원해제
	stmt.close();
	conn.close();
%>