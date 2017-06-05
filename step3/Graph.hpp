//
// Created by Yohsuke Muraes on 2017/06/05.
//

#ifndef GRAPH_HPP
#define GRAPH_HPP

#include <iostream>
#include <vector>
#include <map>
#include <stack>

typedef std::vector< std::vector<long> > components_t;

class Graph {
public:
  Graph(size_t num_nodes);
  void AddLink(long from, long to);
  friend std::ostream &operator<<(std::ostream &os, const Graph &graph);

  void SCCs(components_t& components) const {
    ComponentFinder cf(*this);
    cf.SCCs(components);
  }

private:
  const size_t m_num_nodes;
  std::vector<std::vector<long> > m_links;

  class ComponentFinder {
  public:
    ComponentFinder(const Graph &m_g);
    void SCCs( components_t& components );
  private:
    const Graph& m_g;
    long m_t;
    std::vector<long> desc;
    std::vector<long> low;
    std::stack<long> stack;
    std::vector<bool> on_stack;

    void StrongConnect( long v, components_t& components);
  };
};


#endif //GRAPH_HPP

