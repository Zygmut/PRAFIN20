/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package creador.de.programas;

import java.util.ArrayList;
import java.util.Scanner;

/**
 *
 * @author Zygmut
 */
public class CreadorDeProgramas {

    enum inst {
        EXIT, COPY, ADD, SUB, AND, NOT, STC, LOA, LOAI, STO, STOI, BRI, BRC, BRZ, DONE, REMOVE, HELP, VALUE, X
    }

    ArrayList<String> prog = new ArrayList();
    Scanner sc = new Scanner(System.in);

    String[] op = {"T0", "T1", "R2", "R3", "R4", "R5", "B6", "B7"};
    String[] opc = {"000", "001", "010", "011", "100", "101", "110", "111"};
    String[] opr;

    String b, c, a, m, i;

    boolean valid;

    public void inicio() {
        menu();
        while (true) {
            waitcomm();
            if (!prog.isEmpty()) {
                System.out.println(show());
            }

        }
    }

    public void waitcomm() {
        System.out.print("Command : ");
        String s = sc.nextLine();
        String[] ss = s.split(" ");
        processcomm(ss);
    }

    public void processcomm(String[] s) {
        switch (s[0]) {
            case "EXIT":
                prog.add("$0000");
                break;

            case "COPY":
                opr = s[1].split(",");
                b = opcode(opr[0]);
                c = opcode(opr[1]);
                prog.add("$" + Integer.toHexString(Integer.parseInt("0100000000" + b + c, 2)).toUpperCase());
                break;

            case "ADD":
                opr = s[1].split(",");
                a = opcode(opr[0]);
                b = opcode(opr[1]);
                c = opcode(opr[2]);
                prog.add("$" + Integer.toHexString(Integer.parseInt("0100100" + a + b + c, 2)).toUpperCase());
                break;

            case "SUB":
                opr = s[1].split(",");
                a = opcode(opr[0]);
                b = opcode(opr[1]);
                c = opcode(opr[2]);
                prog.add("$" + Integer.toHexString(Integer.parseInt("0101000" + a + b + c, 2)).toUpperCase());
                break;

            case "AND":
                opr = s[1].split(",");
                a = opcode(opr[0]);
                b = opcode(opr[1]);
                c = opcode(opr[2]);
                prog.add("$" + Integer.toHexString(Integer.parseInt("0101100" + a + b + c, 2)).toUpperCase());
                break;

            case "NOT":
                c = opcode(s[1]);
                prog.add("$" + Integer.toHexString(Integer.parseInt("0110000000000" + c, 2)).toUpperCase());
                break;

            case "STC":
                opr = s[1].split(",");
                String k = Integer.toBinaryString(Integer.parseInt(opr[0].split("#")[1]));
                if (k.length() > 8) {
                    k = k.substring(24);
                } else {
                    while (k.length() < 8) {
                        k = '0' + k;
                    }
                }
                c = opcode(opr[1]);
                prog.add("$" + Integer.toHexString(Integer.parseInt("01101" + k + c, 2)).toUpperCase());
                break;

            case "LOA":
                opr = s[1].split(",");

                m = Integer.toBinaryString(Integer.parseInt(opr[0]));
                if (m.length() > 8) {
                    m = m.substring(24);
                } else {
                    while (m.length() < 8) {
                        m = '0' + m;
                    }
                }

                valid = true;
                switch (opcode(opr[1])) {
                    case "000":
                        i = "0";
                        break;
                    case "001":
                        i = "1";
                        break;
                    default:
                        System.out.println("Needs to be T0 or T1");
                        valid = false;
                }

                if (valid) {
                    prog.add("$" + Integer.toHexString(Integer.parseInt("1000" + i + "000" + m, 2)).toUpperCase());
                }

                break;

            case "LOAI":
                valid = true;
                switch (opcode(s[1].substring(1, 3))) {
                    case "110":
                        i = "0";
                        break;
                    case "111":
                        i = "1";
                        break;
                    default:
                        System.out.println("Needs to be B6 or B7");
                        valid = false;
                }
                if (valid) {
                    prog.add("$" + Integer.toHexString(Integer.parseInt("1001" + i + "00000000000", 2)).toUpperCase());
                }

                break;

            case "STO":
                opr = s[1].split(",");

                m = Integer.toBinaryString(Integer.parseInt(opr[1]));
                if (m.length() > 8) {
                    m = m.substring(24);
                } else {
                    while (m.length() < 8) {
                        m = '0' + m;
                    }
                }

                valid = true;
                switch (opcode(opr[0])) {
                    case "000":
                        i = "0";
                        break;
                    case "001":
                        i = "1";
                        break;
                    default:
                        System.out.println("Needs to be T0 or T1");
                        valid = false;
                }
                if (valid) {
                    prog.add("$" + Integer.toHexString(Integer.parseInt("1010" + i + "000" + m, 2)).toUpperCase());
                }
                break;

            case "STOI":
                valid = true;
                switch (opcode(s[1].substring(1, 3))) {
                    case "110":
                        i = "0";
                        break;
                    case "111":
                        i = "1";
                        break;
                    default:
                        System.out.println("Needs to be B6 or B7");
                        valid = false;
                }
                if (valid) {
                    prog.add("$" + Integer.toHexString(Integer.parseInt("1011" + i + "00000000000", 2)).toUpperCase());
                }

                break;

            case "BRI":

                m = Integer.toBinaryString(Integer.parseInt(s[1]));
                if (m.length() > 8) {
                    m = m.substring(24);
                } else {
                    while (m.length() < 8) {
                        m = '0' + m;
                    }
                }
                prog.add("$" + Integer.toHexString(Integer.parseInt("11000000" + m, 2)).toUpperCase());
                break;

            case "BRC":
                m = Integer.toBinaryString(Integer.parseInt(s[1]));
                if (m.length() > 8) {
                    m = m.substring(24);
                } else {
                    while (m.length() < 8) {
                        m = '0' + m;
                    }
                }
                prog.add("$" + Integer.toHexString(Integer.parseInt("11010000" + m, 2)).toUpperCase());
                break;
            case "BRZ":
                m = Integer.toBinaryString(Integer.parseInt(s[1]));
                if (m.length() > 8) {
                    m = m.substring(24);
                } else {
                    while (m.length() < 8) {
                        m = '0' + m;
                    }
                }
                prog.add("$" + Integer.toHexString(Integer.parseInt("11100000" + m, 2)).toUpperCase());
                break;

            case "DONE":
                System.out.println(prog.toString());
                prog.clear();
                System.out.println("");
                break;

            case "REMOVE":
                if (!prog.isEmpty()) {
                    prog.remove(prog.size() - 1);
                }
                break;

            case "HELP":
                System.out.println("EXIT: \nNada en especial");
                System.out.println("COPY: \nNada en especial (COPY T0,R2)");
                System.out.println("ADD: \nNada en especial (ADD R2,R4,R4)");
                System.out.println("SUB: \nNada en especial (SUB R2,R4,R4)");
                System.out.println("AND: \nNada en especial (AND R2,R3,R3)");
                System.out.println("NOT: \nNada en especial (NOT R3)");
                System.out.println("STC: \nHay que poner el corchete (STC #13,R3)");
                System.out.println("LOA: \nSi es una etiqueta, hay que poner el valor de esta (LOA 13,T1)");
                System.out.println("LOAI: \nHay que poner parentesis (LOAI (B6))");
                System.out.println("STO: \nSi es una etiqueta, hay que poner el valor de esta (STO T0,13)");
                System.out.println("STOI: \nHay que poner parentesis (STOI (B6))");
                System.out.println("BRI: \nSi es una etiqueta, hay que poner el valor de esta (BRI 14)");
                System.out.println("BRC: \nSi es una etiqueta, hay que poner el valor de esta (BRC 14)");
                System.out.println("BRZ: \nSi es una etiqueta, hay que poner el valor de esta (BRZ 14)");
                System.out.println("VALUE: \nNada especial (VALUE -3)");
                System.out.println("REMOVE: \nElimina la ultima instrucción codificacada");
                System.out.println("DONE: \nImprime el vector del programa. No pone DC.W");
                System.out.println("X: \nSale del programa\n");
                break;

            case "VALUE":

                m = Integer.toHexString(Integer.parseInt(s[1])).toUpperCase();
                if (m.length() > 4) {
                    m = m.substring(4);
                } else {
                    while (m.length() < 4) {
                        m = '0' + m;
                    }
                }
                prog.add("$" + m);
                break;

            case "X":
                System.exit(0);
                break;

        }
    }

    public String opcode(String x) {
        try {
            int i;
            for (i = 0; i < op.length; i++) {
                if (x.equals(op[i])) {
                    break;
                }
            }
            return opc[i];
        } catch (Exception e) {
            System.out.println("Arguments not found");
        }
        return "XXX";
    }

    public String show() {
        String s = "";
        for (int j = 0; j < prog.size(); j++) {
            s += j + ": " + prog.get(j) + "\n";
        }
        return s;
    }

    public void menu() {
        System.out.println("Codificador de programas de la PS-ECI ");
        System.out.println("Si necesitas saber que comandos hay escribe HELP. TODOS LOS COMANDOS VAN EN MAYUSCULA ");
    }

    public static void main(String[] args) {
        new CreadorDeProgramas().inicio();
    }

}
